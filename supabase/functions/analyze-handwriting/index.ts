// Edge Function: thin proxy that adds the Gemini API key server-side and
// gates access on a valid Supabase user JWT. The client never sees the key.
//
// Body (JSON):  { image: <base64-encoded jpeg bytes> }
// Response:     200 + Gemini's parsed analysis JSON, or
//               401 missing/invalid JWT,
//               400 malformed body,
//               429 Gemini rate limit (Retry-After forwarded),
//               500 upstream Gemini error or unexpected failure.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const GEMINI_MODEL = "gemini-2.5-flash";
const GEMINI_ENDPOINT =
  `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!,
);

interface GeminiCandidatePart {
  text?: string;
}

interface GeminiCandidate {
  content?: { parts?: GeminiCandidatePart[] };
}

interface GeminiResponse {
  candidates?: GeminiCandidate[];
  error?: { message?: string };
}

function jsonResponse(body: unknown, status: number, headers: HeadersInit = {}) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...headers },
  });
}

function buildGeminiBody(imageBase64: string) {
  return {
    contents: [
      {
        parts: [
          {
            text:
              "Analyze this handwriting sample and provide insights about: " +
              "1. Personality traits based on handwriting style, " +
              "2. Legibility assessment, " +
              "3. Emotional state detection. " +
              "Return the analysis as a JSON object with these three " +
              "categories as keys. Do not include any markdown formatting " +
              "or code blocks in your response, just the raw JSON.",
          },
          { inlineData: { mimeType: "image/jpeg", data: imageBase64 } },
        ],
      },
    ],
    generationConfig: {
      responseMimeType: "application/json",
      temperature: 0,
      responseJsonSchema: {
        type: "object",
        properties: {
          personality_traits: { type: "object", additionalProperties: true },
          legibility_assessment: { type: "object", additionalProperties: true },
          emotional_state: { type: "object", additionalProperties: true },
        },
        required: [
          "personality_traits",
          "legibility_assessment",
          "emotional_state",
        ],
      },
    },
  };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  // 1. Authenticate the caller.
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (!token) {
    return jsonResponse({ error: "Missing Authorization bearer token" }, 401);
  }

  const { data: claimsData, error: claimsError } = await supabase.auth
    .getClaims(token);
  if (claimsError || !claimsData?.claims?.sub) {
    return jsonResponse({ error: "Invalid or expired session" }, 401);
  }

  // 2. Parse the body. Expected shape: { image: <base64> }.
  let imageBase64: string | undefined;
  try {
    const body = await req.json();
    if (body && typeof body === "object" && typeof body.image === "string") {
      imageBase64 = body.image;
    }
  } catch (_) {
    // fall through to validation below
  }
  if (!imageBase64) {
    return jsonResponse(
      { error: "Body must be JSON: { image: <base64-encoded jpeg> }" },
      400,
    );
  }

  // 3. Call Gemini with the server-side API key.
  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  if (!geminiKey) {
    return jsonResponse({ error: "Server is not configured" }, 500);
  }

  const url = `${GEMINI_ENDPOINT}?key=${geminiKey}`;
  let geminiResponse: Response;
  try {
    geminiResponse = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(buildGeminiBody(imageBase64)),
    });
  } catch (err) {
    console.error("Gemini fetch failed", err);
    return jsonResponse({ error: "Upstream unreachable" }, 502);
  }

  // 4. Forward upstream non-2xx as our own typed status.
  if (!geminiResponse.ok) {
    const upstreamMessage = await safeReadMessage(geminiResponse);

    if (geminiResponse.status === 429) {
      const retryAfter = geminiResponse.headers.get("retry-after");
      return jsonResponse(
        { error: upstreamMessage ?? "Gemini rate limited" },
        429,
        retryAfter ? { "Retry-After": retryAfter } : {},
      );
    }
    if (geminiResponse.status === 401 || geminiResponse.status === 403) {
      // Map upstream auth issues to 500 — this is a server-config problem,
      // not the caller's auth. Don't leak that distinction.
      console.error("Gemini auth failure", upstreamMessage);
      return jsonResponse({ error: "Upstream rejected request" }, 500);
    }
    return jsonResponse(
      { error: upstreamMessage ?? `Gemini status ${geminiResponse.status}` },
      geminiResponse.status >= 500 ? 502 : 500,
    );
  }

  // 5. Extract the model's text output (which is itself a JSON string), parse
  //    it once, and return the inner object. Client's parser still standardizes
  //    keys ("Personality Traits" → "personality_traits") since prompt drift is
  //    the model's quirk, not the proxy's.
  let parsedBody: GeminiResponse;
  try {
    parsedBody = (await geminiResponse.json()) as GeminiResponse;
  } catch (err) {
    console.error("Gemini response not JSON", err);
    return jsonResponse({ error: "Malformed upstream response" }, 502);
  }

  const text = (parsedBody.candidates ?? [])
    .flatMap((c) => c.content?.parts ?? [])
    .map((p) => p.text ?? "")
    .join("")
    .trim();

  if (!text) {
    return jsonResponse({ error: "Empty upstream response" }, 502);
  }

  let analysis: unknown;
  try {
    analysis = JSON.parse(text);
  } catch (err) {
    console.error("Inner Gemini text was not JSON", err);
    return jsonResponse({ error: "Malformed upstream payload" }, 502);
  }

  // Optional: log usage for audit/rate-limiting once a `analysis_audit` table
  // exists. Left as a follow-up — this PR is purely the secret-on-server move.
  // await supabase.from('analysis_audit').insert({ user_id: claimsData.claims.sub });

  return jsonResponse(analysis, 200);
});

async function safeReadMessage(resp: Response): Promise<string | null> {
  try {
    const body = await resp.json();
    if (body && typeof body === "object") {
      const msg = (body as { error?: { message?: string } }).error?.message;
      if (typeof msg === "string") return msg;
    }
  } catch (_) {
    /* fall through */
  }
  return null;
}

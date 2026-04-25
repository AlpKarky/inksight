# Supabase Setup — Edge Function for Handwriting Analysis

This branch moves the Gemini API key off the device. The Flutter app now
calls a Supabase Edge Function (`analyze-handwriting`) that proxies the
request to Gemini server-side, gated by the user's Supabase JWT.

These instructions are current as of April 2026. If a CLI command name
or env-var name differs from what you see in the Supabase dashboard /
docs, trust the dashboard.

---

## Prerequisites

- A Supabase project (free tier is fine).
- A Gemini API key. Get one at https://aistudio.google.com/.
- The Supabase CLI: `brew install supabase/tap/supabase`
  - Verify: `supabase --version` (need ≥ 2.0).
- Docker Desktop running, **only** if you want to run the function locally
  with `supabase functions serve`. Not needed for deploy-and-test.

## One-time project setup

From the repo root:

```bash
# 1. Authenticate the CLI with your Supabase account.
#    Opens a browser; copy the access token back into the terminal.
supabase login

# 2. Link this checkout to your remote project.
#    Find <project-ref> in the dashboard URL: app.supabase.com/project/<ref>
supabase link --project-ref <project-ref>
```

This creates a `.supabase/` directory locally — already in `.gitignore`.

## Deploying the function

The function code lives at
[supabase/functions/analyze-handwriting/index.ts](../supabase/functions/analyze-handwriting/index.ts).
Config is at [supabase/config.toml](../supabase/config.toml) — `verify_jwt = true`
so unauthenticated requests are rejected at the edge.

```bash
# 1. Set the Gemini API key as a function secret. NOT in any .env file
#    that ships with the app.
supabase secrets set GEMINI_API_KEY=your-real-gemini-key

# 2. Verify it's set.
supabase secrets list

# 3. Deploy. The CLI bundles supabase/functions/analyze-handwriting/
#    and uploads it.
supabase functions deploy analyze-handwriting
```

The function picks up `GEMINI_API_KEY` from the platform secret store at
runtime. `SUPABASE_URL` and `SUPABASE_ANON_KEY` are auto-injected — do
not set them yourself.

## Verifying it works

After deploy, test from the project's SQL editor or with curl:

```bash
# Get your project's anon key from Settings → API → anon public key.
# (Same key the Flutter app uses as SUPABASE_PUBLISHABLE_KEY.)
ANON_KEY=eyJhbGciOi...

# Sign in once via your app (or via the dashboard) to grab a real JWT.
# A valid user JWT is required — the anon key alone won't pass the
# function's getClaims() check.
USER_JWT=eyJhbGciOi...

curl -X POST \
  https://<project-ref>.supabase.co/functions/v1/analyze-handwriting \
  -H "Authorization: Bearer $USER_JWT" \
  -H "Content-Type: application/json" \
  -d '{"image":"<base64-jpeg>"}'
```

Expected: `{ "personality_traits": {...}, "legibility_assessment": {...},
"emotional_state": {...} }`. A bare anon-key call should return
`401 Invalid or expired session`.

## Removing the device-side key

Once the function is live, the Gemini key can come out of every local
`.env`:

```bash
# In each of these, delete the GEMINI_API_KEY=... line:
.env.dev
.env.staging
.env.prod
```

(`.env.example` is already updated in this branch.)

The app still needs `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` to
sign users in and reach the function.

## Local development against the function

Two options:

**(a) Run against your deployed dev project.** Easiest — point
`.env.dev` at it and you're done. Latency is real but small.

**(b) Run the function locally.** Requires Docker:

```bash
# Loads GEMINI_API_KEY from a .env in supabase/functions/analyze-handwriting/.env
# (gitignored) — separate from your Flutter .env files.
supabase functions serve analyze-handwriting --env-file supabase/functions/analyze-handwriting/.env
```

The Flutter `supabase_flutter` SDK detects local mode automatically when
`SUPABASE_URL` points at `http://localhost:54321`.

## Rotating the key

If the key ever leaks (or as routine hygiene):

```bash
# 1. Generate a new key in Google AI Studio.
# 2. Push it.
supabase secrets set GEMINI_API_KEY=new-key

# 3. Revoke the old key in the AI Studio dashboard.
```

No redeploy needed — secrets are read at function invocation time.

## Future improvements (out of scope for this PR)

- **Per-user rate limiting**: the function already validates the JWT and
  has access to `user_id` via `claimsData.claims.sub`. Add a Postgres
  table `analysis_audit(user_id, created_at)` and reject requests when
  the user has exceeded a daily quota.
- **Audit log**: persist every successful invocation for cost
  attribution and abuse forensics.
- **Response caching**: hash the image bytes; if seen before, return the
  cached analysis without calling Gemini.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `401 Invalid or expired session` from the function | Caller sent the anon key, not a user JWT, or the user's session has expired and the client didn't refresh. |
| `500 Server is not configured` from the function | `GEMINI_API_KEY` secret isn't set. Re-run `supabase secrets set`. |
| Function appears to deploy but invocations 404 | The deployed function name must match the Flutter side's `functionName` (default `analyze-handwriting`). |
| Cold-start latency on the first call | Edge Functions sleep after inactivity. Acceptable for now; consider a periodic warmup ping if it bothers users. |

/// Bounds for client-side image preparation before sending to the analysis API.
abstract final class ImagePipelineLimits {
  /// Longest edge (width or height) after resize, in pixels.
  static const int maxLongSide = 2048;

  /// Target max encoded JPEG size before base64 (Gemini payload limits).
  static const int maxOutputBytes = 4 * 1024 * 1024;

  static const int jpegQualityStart = 85;
  static const int jpegQualityMin = 40;
}

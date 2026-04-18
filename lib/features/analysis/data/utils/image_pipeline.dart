import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:inksight/core/constants/image_pipeline_limits.dart';

/// Thrown when encoded output still exceeds
/// [ImagePipelineLimits.maxOutputBytes].
final class ImageTooLargeForPipelineException implements Exception {
  const ImageTooLargeForPipelineException();
}

/// Top-level entrypoint for isolate workers: decode, resize, re-encode as JPEG.
Uint8List prepareImageForAnalysisBytes(Uint8List rawBytes) {
  final img.Image? decoded;
  try {
    decoded = img.decodeImage(rawBytes);
  } on Object catch (e) {
    throw FormatException('Could not decode image', e);
  }
  if (decoded == null) {
    throw const FormatException('Could not decode image');
  }

  var image = decoded;
  const maxLong = ImagePipelineLimits.maxLongSide;

  if (image.width > maxLong || image.height > maxLong) {
    if (image.width >= image.height) {
      image = img.copyResize(image, width: maxLong);
    } else {
      image = img.copyResize(image, height: maxLong);
    }
  }

  var quality = ImagePipelineLimits.jpegQualityStart;
  var out = Uint8List.fromList(
    img.encodeJpg(image, quality: quality),
  );

  while (out.length > ImagePipelineLimits.maxOutputBytes &&
      quality > ImagePipelineLimits.jpegQualityMin) {
    quality -= 10;
    out = Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  if (out.length > ImagePipelineLimits.maxOutputBytes) {
    image = img.copyResize(
      image,
      width: (image.width * 0.75).round().clamp(1, 1 << 30),
      height: (image.height * 0.75).round().clamp(1, 1 << 30),
    );
    out = Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  if (out.length > ImagePipelineLimits.maxOutputBytes) {
    throw const ImageTooLargeForPipelineException();
  }

  return out;
}

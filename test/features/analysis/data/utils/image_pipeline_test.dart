import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:inksight/features/analysis/data/utils/image_pipeline.dart';

void main() {
  group('prepareImageForAnalysisBytes', () {
    test('returns JPEG bytes for valid input', () {
      final image = img.Image(width: 4, height: 4);
      img.fill(image, color: img.ColorRgb8(10, 20, 30));
      final input = Uint8List.fromList(img.encodePng(image));

      final out = prepareImageForAnalysisBytes(input);

      expect(out, isNotEmpty);
      expect(out[0], 0xFF);
      expect(out[1], 0xD8);
    });

    test('throws FormatException for invalid bytes', () {
      expect(
        () => prepareImageForAnalysisBytes(Uint8List.fromList([0, 1, 2])),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

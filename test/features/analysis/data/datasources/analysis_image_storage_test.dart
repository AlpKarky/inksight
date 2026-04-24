import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/features/analysis/data/datasources/analysis_image_storage.dart';

void main() {
  late Directory tempRoot;
  late AnalysisImageStorageImpl storage;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('inksight_storage_test_');
    storage = AnalysisImageStorageImpl(baseDirectory: tempRoot);
  });

  tearDown(() async {
    if (tempRoot.existsSync()) {
      await tempRoot.delete(recursive: true);
    }
  });

  group('AnalysisImageStorageImpl', () {
    test('save writes bytes and returns a readable path', () async {
      final bytes = Uint8List.fromList(List.generate(16, (i) => i));

      final path = await storage.save(analysisId: 'abc', bytes: bytes);

      expect(path, endsWith('/analyses/abc.jpg'));
      expect(File(path).existsSync(), isTrue);
      expect(await File(path).readAsBytes(), bytes);
    });

    test('save creates the analyses subdirectory if missing', () async {
      expect(
        Directory('${tempRoot.path}/analyses').existsSync(),
        isFalse,
      );

      await storage.save(
        analysisId: 'only-first',
        bytes: Uint8List.fromList([1, 2]),
      );

      expect(
        Directory('${tempRoot.path}/analyses').existsSync(),
        isTrue,
      );
    });

    test('delete removes the image for a saved analysis', () async {
      final path = await storage.save(
        analysisId: 'deleteme',
        bytes: Uint8List.fromList([9, 9]),
      );
      expect(File(path).existsSync(), isTrue);

      await storage.delete('deleteme');

      expect(File(path).existsSync(), isFalse);
    });

    test('delete is a no-op for an unknown id', () async {
      // Must not throw.
      await storage.delete('never-saved');
    });
  });
}

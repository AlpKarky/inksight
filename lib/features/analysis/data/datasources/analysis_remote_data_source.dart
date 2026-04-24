import 'dart:typed_data';

abstract class AnalysisRemoteDataSource {
  Future<Map<String, dynamic>> analyzeHandwriting({
    required Uint8List imageBytes,
  });
}

import 'dart:io';

abstract class AnalysisRemoteDataSource {
  Future<Map<String, dynamic>> analyzeHandwriting({
    required File imageFile,
  });
}

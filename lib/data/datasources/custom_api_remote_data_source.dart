import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CustomApiRemoteDataSource {
  Future<Map<String, dynamic>> analyzeHandwriting({
    required File imageFile,
    required String apiUrl,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      return data as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to analyze with custom API: ${response.statusCode}. Response: $responseBody',
    );
  }
}

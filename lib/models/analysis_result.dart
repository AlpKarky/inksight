class AnalysisResult {
  final String id;
  final DateTime timestamp;
  final String imagePath;
  final Map<String, dynamic> analysis;

  AnalysisResult({
    required this.id,
    required this.timestamp,
    required this.imagePath,
    required this.analysis,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
      analysis: json['analysis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'analysis': analysis,
    };
  }
}

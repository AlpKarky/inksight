import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inksight/models/analysis_result.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult analysisResult;

  const ResultScreen({super.key, required this.analysisResult});

  @override
  Widget build(BuildContext context) {
    final personalityTraits = analysisResult.analysis['personality_traits'];
    final legibilityAssessment =
        analysisResult.analysis['legibility_assessment'];
    final emotionalState = analysisResult.analysis['emotional_state'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(analysisResult.imagePath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              // Timestamp
              Text(
                'Analysis completed on ${_formatDate(analysisResult.timestamp)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Personality Traits
              _buildSection(
                context,
                'Personality Traits',
                Icons.psychology,
                Colors.blue,
                _buildPersonalityTraitsContent(personalityTraits),
              ),
              const SizedBox(height: 16),

              // Legibility Assessment
              _buildSection(
                context,
                'Legibility Assessment',
                Icons.rate_review,
                Colors.green,
                _buildLegibilityContent(legibilityAssessment),
              ),
              const SizedBox(height: 16),

              // Emotional State
              _buildSection(
                context,
                'Emotional State',
                Icons.mood,
                Colors.orange,
                _buildEmotionalStateContent(emotionalState),
              ),

              // If it's a mock result, show a note
              if (analysisResult.analysis.containsKey('note'))
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(51), // 0.2 opacity
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            analysisResult.analysis['note'],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement save functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Analysis saved')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Analysis'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withAlpha(26), // 0.1 opacity
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityTraitsContent(dynamic personalityTraits) {
    if (personalityTraits is String) {
      return Text(personalityTraits);
    }

    final traits = personalityTraits['traits'];
    final confidence = personalityTraits['confidence'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (confidence != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Confidence: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(confidence),
              ],
            ),
          ),
        if (traits is List)
          ...traits.map((trait) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(trait.toString())),
                  ],
                ),
              )),
        if (traits is! List) Text(traits.toString()),
      ],
    );
  }

  Widget _buildLegibilityContent(dynamic legibilityAssessment) {
    if (legibilityAssessment is String) {
      return Text(legibilityAssessment);
    }

    final score = legibilityAssessment['score'];
    final comments = legibilityAssessment['comments'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (score != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Score: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('$score/10'),
              ],
            ),
          ),
        if (comments != null) Text(comments.toString()),
      ],
    );
  }

  Widget _buildEmotionalStateContent(dynamic emotionalState) {
    if (emotionalState is String) {
      return Text(emotionalState);
    }

    final primaryEmotion = emotionalState['primary_emotion'];
    final notes = emotionalState['notes'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (primaryEmotion != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Primary Emotion: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(primaryEmotion),
              ],
            ),
          ),
        if (notes != null) Text(notes.toString()),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month $day, $year at $hour:$minute';
  }
}

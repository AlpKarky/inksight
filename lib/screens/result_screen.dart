import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_history_repository.dart';
import 'package:inksight/utils/result.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult analysisResult;

  const ResultScreen({super.key, required this.analysisResult});

  @override
  Widget build(BuildContext context) {
    // Extract analysis data, handling different possible formats
    final personalityTraits =
        _extractAnalysisSection(analysisResult.analysis, 'personality_traits');
    final legibilityAssessment = _extractAnalysisSection(
        analysisResult.analysis, 'legibility_assessment');
    final emotionalState =
        _extractAnalysisSection(analysisResult.analysis, 'emotional_state');

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

              // If raw response is available, add a button to view it
              if (analysisResult.analysis.containsKey('raw_response'))
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Raw API Response'),
                            content: SingleChildScrollView(
                              child: Text(
                                  analysisResult.analysis['raw_response'] ??
                                      'No raw response available'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('View Raw API Response'),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final repository =
                        context.read<AnalysisHistoryRepository>();
                    final result =
                        await repository.saveAnalysis(analysisResult);

                    if (!context.mounted) return;

                    switch (result) {
                      case Ok<void>():
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Analysis saved')),
                        );
                      case Error<void>():
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save analysis'),
                          ),
                        );
                    }
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

  // Helper method to extract analysis sections with different possible formats
  dynamic _extractAnalysisSection(Map<String, dynamic> analysis, String key) {
    // Map of standard keys to the actual keys in the API response
    final keyMappings = {
      'personality_traits': ['Personality traits based on handwriting style'],
      'legibility_assessment': ['Legibility assessment'],
      'emotional_state': ['Emotional state detection']
    };

    // Check if we have a mapping for this key
    if (keyMappings.containsKey(key)) {
      for (final mappedKey in keyMappings[key]!) {
        if (analysis.containsKey(mappedKey)) {
          final value = analysis[mappedKey];
          return value;
        }
      }
    }

    // If no mapping found, try direct key match
    if (analysis.containsKey(key)) {
      final value = analysis[key];
      return value;
    }

    // Try with capitalized key (Gemini might return capitalized keys)
    final capitalizedKey = key
        .split('_')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join('');

    if (analysis.containsKey(capitalizedKey)) {
      final value = analysis[capitalizedKey];
      return value;
    }

    // Try with spaces instead of underscores
    final spacedKey = key.replaceAll('_', ' ');
    if (analysis.containsKey(spacedKey)) {
      final value = analysis[spacedKey];
      return value;
    }

    // Try with capitalized spaced key
    final capitalizedSpacedKey = spacedKey
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');

    if (analysis.containsKey(capitalizedSpacedKey)) {
      final value = analysis[capitalizedSpacedKey];
      return value;
    }

    // Return empty map as fallback
    return {};
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
    if (personalityTraits == null) {
      return const Text('No personality traits information available');
    }

    // If it's a string, just display it directly
    if (personalityTraits is String) {
      return Text(personalityTraits);
    }

    // Handle different possible formats from Gemini API
    List<Widget> children = [];

    // If it's a map, try to extract structured data
    if (personalityTraits is Map) {
      // Check for traits list
      final traits = _getValueFromMap(
          personalityTraits, ['traits', 'Traits', 'trait', 'Trait']);
      final description = _getValueFromMap(personalityTraits,
          ['description', 'Description', 'summary', 'Summary']);
      final confidence =
          _getValueFromMap(personalityTraits, ['confidence', 'Confidence']);
      final disclaimer = _getValueFromMap(
          personalityTraits, ['disclaimer', 'Disclaimer', 'note', 'Note']);

      // Add description if available
      if (description != null && description.toString().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(description.toString()),
          ),
        );
      }

      // Add confidence if available
      if (confidence != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Confidence: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(confidence.toString()),
              ],
            ),
          ),
        );
      }

      // Add traits header if traits are available
      if (traits != null && (traits is List || traits.toString().isNotEmpty)) {
        children.add(
          const Padding(
            padding: EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              'Key Traits:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      }

      // Add traits if available as a list
      if (traits is List) {
        for (var trait in traits) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(trait.toString())),
                ],
              ),
            ),
          );
        }
      }
      // If traits is a string, display it directly
      else if (traits is String && traits.isNotEmpty) {
        children.add(Text(traits));
      }
      // If no traits found but the map has other entries, display them
      else if (personalityTraits.isNotEmpty) {
        // Filter out known keys and display the rest
        personalityTraits.forEach((key, value) {
          if (key != 'confidence' &&
              key != 'Confidence' &&
              key != 'traits' &&
              key != 'Traits' &&
              key != 'description' &&
              key != 'Description' &&
              key != 'disclaimer' &&
              key != 'Disclaimer' &&
              key != 'note' &&
              key != 'Note' &&
              value != null &&
              value.toString().isNotEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                        child: Text('${key.toString()}: ${value.toString()}')),
                  ],
                ),
              ),
            );
          }
        });
      }

      // Add disclaimer if available
      if (disclaimer != null && disclaimer.toString().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                disclaimer.toString(),
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ),
          ),
        );
      }
    }

    // If no structured content was found, display the raw value
    if (children.isEmpty) {
      if (personalityTraits.toString().isNotEmpty) {
        children.add(Text(personalityTraits.toString()));
      } else {
        children.add(const Text('No specific personality traits identified'));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildLegibilityContent(dynamic legibilityAssessment) {
    if (legibilityAssessment == null) {
      return const Text('No legibility assessment available');
    }

    if (legibilityAssessment is String) {
      return Text(legibilityAssessment);
    }

    // Handle different possible formats from Gemini API
    List<Widget> children = [];

    if (legibilityAssessment is Map) {
      // Try to extract score and comments
      final score = _getValueFromMap(
          legibilityAssessment, ['score', 'Score', 'rating', 'Rating']);
      final overall = _getValueFromMap(
          legibilityAssessment, ['overall', 'Overall', 'summary', 'Summary']);
      final comments = _getValueFromMap(legibilityAssessment, [
        'comments',
        'Comments',
        'comment',
        'Comment',
        'assessment',
        'Assessment'
      ]);
      final specifics = _getValueFromMap(legibilityAssessment,
          ['specifics', 'Specifics', 'details', 'Details']);
      final recommendations = _getValueFromMap(legibilityAssessment,
          ['recommendations', 'Recommendations', 'suggestions', 'Suggestions']);

      // Add overall assessment if available
      if (overall != null && overall.toString().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(overall.toString()),
          ),
        );
      }

      // Add score if available
      if (score != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Score: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(score is num ? '$score/10' : score.toString()),
              ],
            ),
          ),
        );
      }

      // Add comments if available
      if (comments != null &&
          comments.toString().isNotEmpty &&
          comments != overall) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(comments.toString()),
          ),
        );
      }

      // Add specifics if available
      if (specifics != null) {
        children.add(
          const Padding(
            padding: EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              'Specific Observations:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );

        if (specifics is List) {
          for (var specific in specifics) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(specific.toString())),
                  ],
                ),
              ),
            );
          }
        } else if (specifics is String && specifics.isNotEmpty) {
          children.add(Text(specifics));
        }
      }

      // Add recommendations if available
      if (recommendations != null && recommendations.toString().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommendations:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(recommendations.toString()),
              ],
            ),
          ),
        );
      }

      // If no specific fields found but the map has other entries, display them
      if (children.isEmpty && legibilityAssessment.isNotEmpty) {
        // Filter out known keys and display the rest
        legibilityAssessment.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${key.toString()}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(value.toString()),
                  ],
                ),
              ),
            );
          }
        });
      }
    }

    // If no structured content was found, display the raw value
    if (children.isEmpty) {
      if (legibilityAssessment.toString().isNotEmpty) {
        children.add(Text(legibilityAssessment.toString()));
      } else {
        children.add(const Text('No specific legibility details available'));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildEmotionalStateContent(dynamic emotionalState) {
    if (emotionalState == null) {
      return const Text('No emotional state information available');
    }

    if (emotionalState is String) {
      return Text(emotionalState);
    }

    // Handle different possible formats from Gemini API
    List<Widget> children = [];

    if (emotionalState is Map) {
      // Try to extract primary emotion and notes
      final emotionKeys = [
        'primary_emotion',
        'primaryEmotion',
        'Primary Emotion',
        'primary emotion',
        'emotion',
        'Emotion',
        'state',
        'State'
      ];

      final noteKeys = [
        'notes',
        'Notes',
        'note',
        'Note',
        'description',
        'Description',
        'details',
        'Details',
        'analysis',
        'Analysis'
      ];

      final primaryEmotion = _getValueFromMap(emotionalState, emotionKeys);
      final overall = _getValueFromMap(
          emotionalState, ['overall', 'Overall', 'summary', 'Summary']);
      final notes = _getValueFromMap(emotionalState, noteKeys);
      final indicators = _getValueFromMap(
          emotionalState, ['indicators', 'Indicators', 'signs', 'Signs']);
      final disclaimer = _getValueFromMap(
          emotionalState, ['disclaimer', 'Disclaimer', 'note', 'Note']);

      // Add overall assessment if available
      if (overall != null && overall.toString().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(overall.toString()),
          ),
        );
      }

      // Add primary emotion if available
      if (primaryEmotion != null && primaryEmotion.toString().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Primary Emotion: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(primaryEmotion.toString()),
              ],
            ),
          ),
        );
      }

      // Add notes if available and not the same as overall
      if (notes != null && notes.toString().isNotEmpty && notes != overall) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(notes.toString()),
          ),
        );
      }

      // Add indicators if available
      if (indicators != null) {
        children.add(
          const Padding(
            padding: EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              'Emotional Indicators:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );

        if (indicators is List) {
          for (var indicator in indicators) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(indicator.toString())),
                  ],
                ),
              ),
            );
          }
        } else if (indicators is String && indicators.isNotEmpty) {
          children.add(Text(indicators));
        }
      }

      // Add disclaimer if available
      if (disclaimer != null && disclaimer.toString().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                disclaimer.toString(),
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ),
          ),
        );
      }

      // If no specific fields found but the map has other entries, display them
      if (children.isEmpty && emotionalState.isNotEmpty) {
        // Filter out known keys and display the rest
        emotionalState.forEach((key, value) {
          if (!emotionKeys.contains(key) &&
              !noteKeys.contains(key) &&
              key != 'indicators' &&
              key != 'Indicators' &&
              key != 'disclaimer' &&
              key != 'Disclaimer' &&
              key != 'overall' &&
              key != 'Overall' &&
              value != null &&
              value.toString().isNotEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${key.toString()}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(value.toString()),
                  ],
                ),
              ),
            );
          }
        });
      }
    }

    // If no structured content was found, display the raw value
    if (children.isEmpty) {
      if (emotionalState.toString().isNotEmpty) {
        children.add(Text(emotionalState.toString()));
      } else {
        children
            .add(const Text('No specific emotional state details available'));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // Helper method to get a value from a map using multiple possible keys
  dynamic _getValueFromMap(Map map, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key];
      }
    }
    return null;
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

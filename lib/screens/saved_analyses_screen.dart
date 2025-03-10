import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/screens/result_screen.dart';
import 'package:inksight/services/storage_service.dart';
import 'package:intl/intl.dart';

class SavedAnalysesScreen extends StatefulWidget {
  const SavedAnalysesScreen({super.key});

  @override
  State<SavedAnalysesScreen> createState() => _SavedAnalysesScreenState();
}

class _SavedAnalysesScreenState extends State<SavedAnalysesScreen> {
  final StorageService _storageService = StorageService();
  List<AnalysisResult> _savedAnalyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAnalyses();
  }

  Future<void> _loadSavedAnalyses() async {
    setState(() {
      _isLoading = true;
    });

    final analyses = await _storageService.getSavedAnalyses();

    // Sort analyses by timestamp (newest first)
    analyses.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _savedAnalyses = analyses;
      _isLoading = false;
    });
  }

  Future<void> _deleteAnalysis(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Analysis'),
        content: const Text('Are you sure you want to delete this analysis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _storageService.deleteAnalysis(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis deleted')),
        );
        _loadSavedAnalyses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete analysis')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Analyses'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedAnalyses.isEmpty
              ? _buildEmptyState()
              : _buildAnalysisList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved analyses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyses you save will appear here',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedAnalyses.length,
      itemBuilder: (context, index) {
        final analysis = _savedAnalyses[index];
        return _buildAnalysisCard(analysis);
      },
    );
  }

  Widget _buildAnalysisCard(AnalysisResult analysis) {
    // Check if the image file exists
    final imageFile = File(analysis.imagePath);
    final imageExists = imageFile.existsSync();

    // Format the date
    final formattedDate =
        DateFormat('MMM d, yyyy • h:mm a').format(analysis.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(analysisResult: analysis),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            if (imageExists)
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),

            // Analysis details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Analysis summary
                  Text(
                    'Handwriting Analysis',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ResultScreen(analysisResult: analysis),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('View'),
                      ),
                      TextButton.icon(
                        onPressed: () => _deleteAnalysis(analysis.id),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

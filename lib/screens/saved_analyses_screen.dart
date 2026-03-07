import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inksight/models/analysis_result.dart';
import 'package:inksight/repositories/analysis_history_repository.dart';
import 'package:inksight/screens/result_screen.dart';
import 'package:inksight/view_models/saved_analyses_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SavedAnalysesScreen extends StatefulWidget {
  const SavedAnalysesScreen({super.key});

  @override
  State<SavedAnalysesScreen> createState() => _SavedAnalysesScreenState();
}

class _SavedAnalysesScreenState extends State<SavedAnalysesScreen> {
  late final SavedAnalysesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SavedAnalysesViewModel(
      historyRepository: context.read<AnalysisHistoryRepository>(),
    );
    _viewModel.loadSavedAnalyses();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
      final success = await _viewModel.deleteAnalysis(id);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis deleted')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete analysis')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Saved Analyses'),
          centerTitle: true,
        ),
        body: _viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _viewModel.savedAnalyses.isEmpty
                ? _buildEmptyState()
                : _buildAnalysisList(),
      ),
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
      itemCount: _viewModel.savedAnalyses.length,
      itemBuilder: (context, index) {
        final analysis = _viewModel.savedAnalyses[index];
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

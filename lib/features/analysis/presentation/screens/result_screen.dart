import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inksight/app/router/routes.dart';
import 'package:inksight/core/extensions/context_extensions.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_viewmodel.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/history_viewmodel.dart';
import 'package:inksight/features/analysis/presentation/widgets/analysis_section_card.dart';
import 'package:inksight/shared/widgets/app_button.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isSaving = false;

  Future<void> _saveAndNavigate() async {
    final analysis = ref.read(analysisViewModelProvider).value;
    if (analysis == null) return;

    setState(() => _isSaving = true);

    final saved = await ref
        .read(historyViewModelProvider.notifier)
        .saveAnalysis(analysis);

    if (!mounted) return;

    if (saved) {
      context.pushReplacement(Routes.history);
    } else {
      setState(() => _isSaving = false);
      context.showSnackBar(
        context.tr('errors.unknown'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(analysisViewModelProvider).value;
    final dims = context.dimensions;

    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.tr('analysis.results_title')),
        ),
        body: Center(
          child: Text(context.tr('analysis.no_results')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('analysis.results_title')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(dims.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImagePreview(imagePath: analysis.imagePath),
            SizedBox(height: dims.spacingMd),
            Text(
              context.tr(
                'analysis.completed_on',
                namedArgs: {
                  'date': DateFormat.yMMMd()
                      .add_jm()
                      .format(analysis.timestamp),
                },
              ),
              style: context.appTextTheme.bodyMedium.copyWith(
                color: context.appColors.textSubtle,
              ),
            ),
            SizedBox(height: dims.spacingLg),
            AnalysisSectionCard(
              title: context.tr('analysis.personality_traits'),
              icon: Icons.psychology,
              color: Colors.blue,
              data: analysis.personalityTraits.data,
            ),
            SizedBox(height: dims.spacingMd),
            AnalysisSectionCard(
              title: context.tr('analysis.legibility'),
              icon: Icons.rate_review,
              color: Colors.green,
              data: analysis.legibilityAssessment.data,
            ),
            SizedBox(height: dims.spacingMd),
            AnalysisSectionCard(
              title: context.tr('analysis.emotional_state'),
              icon: Icons.mood,
              color: Colors.orange,
              data: analysis.emotionalState.data,
            ),
            SizedBox(height: dims.spacingLg),
            AppButton(
              label: context.tr('analysis.save_button'),
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _saveAndNavigate,
            ),
            SizedBox(height: dims.spacingMd),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    if (!file.existsSync()) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: context.appColors.surfaceVariant,
          borderRadius: BorderRadius.circular(
            context.dimensions.radiusLg,
          ),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        context.dimensions.radiusLg,
      ),
      child: Image.file(
        file,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

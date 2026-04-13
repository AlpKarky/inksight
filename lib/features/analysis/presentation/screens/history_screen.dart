import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inksight/app/router/routes.dart';
import 'package:inksight/core/extensions/context_extensions.dart';
import 'package:inksight/features/analysis/domain/entities/analysis_entity.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_viewmodel.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/history_viewmodel.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('analysis.history')),
      ),
      body: state.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          error: error,
          onRetry: () => ref.invalidate(historyViewModelProvider),
        ),
        data: (analyses) => analyses.isEmpty
            ? _EmptyState()
            : _AnalysisList(analyses: analyses),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dimensions.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: context.appColors.error,
            ),
            SizedBox(height: context.dimensions.spacingMd),
            Text(
              context.tr('analysis.load_error'),
              style: context.appTextTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.dimensions.spacingSm),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(context.tr('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: context.appColors.textSubtle,
          ),
          SizedBox(height: context.dimensions.spacingMd),
          Text(
            context.tr('analysis.no_saved'),
            style: context.appTextTheme.titleMedium,
          ),
          SizedBox(height: context.dimensions.spacingSm),
          Text(
            context.tr('analysis.no_saved_hint'),
            style: context.appTextTheme.bodyMedium.copyWith(
              color: context.appColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisList extends ConsumerWidget {
  const _AnalysisList({required this.analyses});

  final List<AnalysisEntity> analyses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: EdgeInsets.all(context.dimensions.spacingMd),
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final analysis = analyses[index];
        return _AnalysisCard(
          analysis: analysis,
          onTap: () async {
            ref
                .read(analysisViewModelProvider.notifier)
                .setResult(analysis);
            await context.push<void>(Routes.result);
          },
          onDelete: () async {
            final confirmed = await _confirmDelete(context);
            if (confirmed && context.mounted) {
              await ref
                  .read(historyViewModelProvider.notifier)
                  .deleteAnalysis(analysis.id);
              if (!context.mounted) return;
              context.showSnackBar(
                context.tr('analysis.deleted'),
              );
            }
          },
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.tr('analysis.delete_title')),
            content: Text(context.tr('analysis.delete_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.tr('common.cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.tr('common.delete')),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.analysis,
    required this.onTap,
    required this.onDelete,
  });

  final AnalysisEntity analysis;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final imageFile = File(analysis.imagePath);
    final imageExists = imageFile.existsSync();
    final formattedDate =
        DateFormat.yMMMd().add_jm().format(analysis.timestamp);

    return Card(
      margin: EdgeInsets.only(bottom: dims.spacingMd),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dims.radiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: imageExists
                  ? Image.file(imageFile, fit: BoxFit.cover)
                  : ColoredBox(
                      color: context.appColors.surfaceVariant,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(dims.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: context.appTextTheme.bodyMedium.copyWith(
                      color: context.appColors.textSubtle,
                    ),
                  ),
                  SizedBox(height: dims.spacingSm),
                  Text(
                    context.tr('analysis.card_title'),
                    style: context.appTextTheme.titleMedium,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility),
                        label: Text(context.tr('analysis.view')),
                      ),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(context.tr('common.delete')),
                        style: TextButton.styleFrom(
                          foregroundColor: context.appColors.error,
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

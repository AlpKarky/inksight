import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inksight/app/router/routes.dart';
import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/extensions/context_extensions.dart';
import 'package:inksight/features/analysis/domain/analysis_pipeline_phase.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_pipeline_phase_viewmodel.dart';
import 'package:inksight/features/analysis/presentation/viewmodels/analysis_viewmodel.dart';
import 'package:inksight/features/analysis/presentation/widgets/image_picker_section.dart';
import 'package:inksight/shared/presentation/failure_mapper.dart';
import 'package:inksight/shared/widgets/app_button.dart';
import 'package:inksight/shared/widgets/loading_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null && mounted) {
      await _cropImage(pickedFile.path);
    }
  }

  Future<void> _cropImage(String filePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: context.tr('analysis.crop_title'),
          toolbarColor: context.appColors.primary,
          toolbarWidgetColor: context.appColors.onPrimary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: context.tr('analysis.crop_title'),
        ),
      ],
    );

    if (croppedFile != null && mounted) {
      setState(() {
        _selectedImage = File(croppedFile.path);
      });
    }
  }

  Future<void> _analyzeHandwriting() async {
    if (_selectedImage == null) return;
    await ref
        .read(analysisViewModelProvider.notifier)
        .analyzeHandwriting(_selectedImage!);
    if (!mounted) return;
    final after = ref.read(analysisViewModelProvider);
    if (after.hasValue && after.value != null) {
      await context.push(Routes.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisViewModelProvider);
    final pipelinePhase = ref.watch(analysisPipelinePhaseProvider);
    final dims = context.dimensions;

    final loadingMessage = state.isLoading
        ? switch (pipelinePhase) {
            AnalysisPipelinePhase.preparing => context.tr(
              'analysis.preparing_image',
            ),
            AnalysisPipelinePhase.analyzing => context.tr('analysis.analyzing'),
            AnalysisPipelinePhase.idle => context.tr(
              'analysis.preparing_image',
            ),
          }
        : null;

    ref.listen(analysisViewModelProvider, (_, next) {
      if (next.hasError && next.error is AppFailure) {
        context.showSnackBar(
          FailureMapper.toMessage(
            next.error! as AppFailure,
            context,
          ),
        );
      }
    });

    return LoadingOverlay(
      isLoading: state.isLoading,
      message: loadingMessage,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('app.name')),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: context.tr('settings.tooltip'),
              onPressed: () => context.push(Routes.settings),
            ),
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: context.tr('analysis.history'),
              onPressed: () => context.push(Routes.history),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(dims.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: dims.spacingMd),
              _HomeHeader(),
              SizedBox(height: dims.spacingXl),
              ImagePickerSection(
                selectedImage: _selectedImage,
                onCameraTap: () => _pickImage(ImageSource.camera),
                onGalleryTap: () => _pickImage(ImageSource.gallery),
              ),
              SizedBox(height: dims.spacingXl),
              AppButton(
                label: context.tr('analysis.analyze_button'),
                onPressed: _selectedImage != null
                    ? () async => _analyzeHandwriting()
                    : null,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.tr('analysis.title'),
          style: context.appTextTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.dimensions.spacingSm),
        Text(
          context.tr('analysis.subtitle'),
          style: context.appTextTheme.bodyMedium.copyWith(
            color: context.appColors.textSubtle,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

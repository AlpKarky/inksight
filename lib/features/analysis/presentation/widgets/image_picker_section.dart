import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:inksight/core/extensions/context_extensions.dart';

class ImagePickerSection extends StatelessWidget {
  const ImagePickerSection({
    required this.selectedImage,
    required this.onCameraTap,
    required this.onGalleryTap,
    super.key,
  });

  final File? selectedImage;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ImagePreview(image: selectedImage),
        SizedBox(height: context.dimensions.spacingMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SourceButton(
              icon: Icons.camera_alt,
              label: context.tr('analysis.camera'),
              onPressed: onCameraTap,
            ),
            _SourceButton(
              icon: Icons.photo_library,
              label: context.tr('analysis.gallery'),
              onPressed: onGalleryTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image});

  final File? image;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;

    if (image == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: context.appColors.surfaceVariant,
          borderRadius: BorderRadius.circular(dims.radiusLg),
        ),
        child: Center(
          child: Text(
            context.tr('analysis.no_image'),
            style: context.appTextTheme.bodyMedium.copyWith(
              color: context.appColors.textSubtle,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(dims.radiusLg),
      child: Image.file(
        image!,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

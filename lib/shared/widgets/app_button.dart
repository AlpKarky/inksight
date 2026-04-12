import 'package:flutter/material.dart';
import 'package:inksight/core/extensions/context_extensions.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: context.dimensions.iconMd,
              width: context.dimensions.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.appColors.onPrimary,
              ),
            )
          : Text(label),
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

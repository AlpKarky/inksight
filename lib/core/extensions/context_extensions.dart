import 'package:flutter/material.dart';
import 'package:inksight/core/theme/app_colors.dart';
import 'package:inksight/core/theme/app_dimensions.dart';
import 'package:inksight/core/theme/app_text_theme.dart';

extension BuildContextExtensions on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;

  AppTextThemeExtension get appTextTheme =>
      Theme.of(this).extension<AppTextThemeExtension>()!;

  AppDimensions get dimensions => AppDimensions.of(this);

  ThemeData get theme => Theme.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

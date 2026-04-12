import 'package:flutter/material.dart';
import 'package:inksight/core/theme/app_colors.dart';
import 'package:inksight/core/theme/app_dimensions.dart';
import 'package:inksight/core/theme/app_text_theme.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const colors = AppColorsExtension.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: colors.primary,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensionsExtension.standard.radiusMd,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensionsExtension.standard.spacingLg,
            vertical: AppDimensionsExtension.standard.spacingMd,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensionsExtension.standard.radiusMd,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensionsExtension.standard.radiusMd,
          ),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensionsExtension.standard.radiusMd,
          ),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensionsExtension.standard.spacingMd,
          vertical: AppDimensionsExtension.standard.spacingMd,
        ),
      ),
      extensions: const [
        AppColorsExtension.light,
        AppTextThemeExtension.light,
        AppDimensionsExtension.standard,
      ],
    );
  }

  static ThemeData get dark {
    const colors = AppColorsExtension.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: colors.primary,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensionsExtension.standard.radiusMd,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensionsExtension.standard.spacingLg,
            vertical: AppDimensionsExtension.standard.spacingMd,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensionsExtension.standard.radiusMd,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensionsExtension.standard.radiusMd,
          ),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensionsExtension.standard.radiusMd,
          ),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensionsExtension.standard.spacingMd,
          vertical: AppDimensionsExtension.standard.spacingMd,
        ),
      ),
      extensions: const [
        AppColorsExtension.dark,
        AppTextThemeExtension.dark,
        AppDimensionsExtension.standard,
      ],
    );
  }
}

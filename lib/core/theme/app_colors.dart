import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.onError,
    required this.outline,
    required this.surfaceVariant,
    required this.textSubtle,
  });

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color background;
  final Color onBackground;
  final Color error;
  final Color onError;
  final Color outline;
  final Color surfaceVariant;
  final Color textSubtle;

  static const light = AppColorsExtension(
    primary: Color(0xFF3F51B5),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF5C6BC0),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1C1B1F),
    background: Color(0xFFF5F5F5),
    onBackground: Color(0xFF1C1B1F),
    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF79747E),
    surfaceVariant: Color(0xFFE7E0EC),
    textSubtle: Color(0xFF6B6B6B),
  );

  static const dark = AppColorsExtension(
    primary: Color(0xFF9FA8DA),
    onPrimary: Color(0xFF1A1A2E),
    secondary: Color(0xFF7986CB),
    surface: Color(0xFF1E1E2E),
    onSurface: Color(0xFFE6E1E5),
    background: Color(0xFF121212),
    onBackground: Color(0xFFE6E1E5),
    error: Color(0xFFCF6679),
    onError: Color(0xFF1C1B1F),
    outline: Color(0xFF938F99),
    surfaceVariant: Color(0xFF2D2D3F),
    textSubtle: Color(0xFF9E9E9E),
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? surface,
    Color? onSurface,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? onError,
    Color? outline,
    Color? surfaceVariant,
    Color? textSubtle,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      outline: outline ?? this.outline,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textSubtle: textSubtle ?? this.textSubtle,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
    );
  }
}

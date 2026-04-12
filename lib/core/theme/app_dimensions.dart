import 'package:flutter/material.dart';

class AppDimensionsExtension extends ThemeExtension<AppDimensionsExtension> {
  const AppDimensionsExtension({
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.spacingXxl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusFull,
    required this.iconSm,
    required this.iconMd,
    required this.iconLg,
  });

  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacingXxl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusFull;
  final double iconSm;
  final double iconMd;
  final double iconLg;

  static const standard = AppDimensionsExtension(
    spacingXs: 4,
    spacingSm: 8,
    spacingMd: 16,
    spacingLg: 24,
    spacingXl: 32,
    spacingXxl: 48,
    radiusSm: 4,
    radiusMd: 8,
    radiusLg: 16,
    radiusFull: 999,
    iconSm: 16,
    iconMd: 24,
    iconLg: 32,
  );

  @override
  ThemeExtension<AppDimensionsExtension> copyWith({
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacingXxl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusFull,
    double? iconSm,
    double? iconMd,
    double? iconLg,
  }) {
    return AppDimensionsExtension(
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXxl: spacingXxl ?? this.spacingXxl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusFull: radiusFull ?? this.radiusFull,
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      iconLg: iconLg ?? this.iconLg,
    );
  }

  @override
  ThemeExtension<AppDimensionsExtension> lerp(
    covariant ThemeExtension<AppDimensionsExtension>? other,
    double t,
  ) {
    if (other is! AppDimensionsExtension) return this;
    return AppDimensionsExtension(
      spacingXs: _lerpDouble(spacingXs, other.spacingXs, t),
      spacingSm: _lerpDouble(spacingSm, other.spacingSm, t),
      spacingMd: _lerpDouble(spacingMd, other.spacingMd, t),
      spacingLg: _lerpDouble(spacingLg, other.spacingLg, t),
      spacingXl: _lerpDouble(spacingXl, other.spacingXl, t),
      spacingXxl: _lerpDouble(spacingXxl, other.spacingXxl, t),
      radiusSm: _lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: _lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: _lerpDouble(radiusLg, other.radiusLg, t),
      radiusFull: _lerpDouble(radiusFull, other.radiusFull, t),
      iconSm: _lerpDouble(iconSm, other.iconSm, t),
      iconMd: _lerpDouble(iconMd, other.iconMd, t),
      iconLg: _lerpDouble(iconLg, other.iconLg, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

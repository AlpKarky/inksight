import 'package:flutter/widgets.dart';

/// Responsive dimensions that scale spacing proportionally to screen width.
///
/// Radii and icon sizes stay fixed because they are not layout-sensitive.
/// Spacing values scale using `screenWidth / designWidth` so the layout
/// adapts across phones, foldables, and tablets.
class AppDimensions {
  const AppDimensions._({required double scale}) : _scale = scale;

  factory AppDimensions.of(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / _designWidth).clamp(
      _minScale,
      _maxScale,
    );
    return AppDimensions._(scale: scale);
  }

  /// For contexts where MediaQuery is unavailable (e.g. ThemeData setup).
  static const fallback = AppDimensions._(scale: 1);

  static const double _designWidth = 375;
  static const double _minScale = 0.85;
  static const double _maxScale = 1.4;

  final double _scale;

  // -- Responsive spacing --

  double get spacingXs => 4 * _scale;
  double get spacingSm => 8 * _scale;
  double get spacingMd => 16 * _scale;
  double get spacingLg => 24 * _scale;
  double get spacingXl => 32 * _scale;
  double get spacingXxl => 48 * _scale;

  // -- Fixed radii (not screen-dependent) --

  double get radiusSm => 4;
  double get radiusMd => 8;
  double get radiusLg => 16;
  double get radiusFull => 999;

  // -- Fixed icon sizes --

  double get iconSm => 16;
  double get iconMd => 24;
  double get iconLg => 32;

  /// Scale factor exposed for custom one-off calculations.
  double get scaleFactor => _scale;
}

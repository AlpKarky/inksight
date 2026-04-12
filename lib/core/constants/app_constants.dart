abstract final class AppConstants {
  // Storage keys
  static const savedAnalysesKey = 'saved_analyses';
  static const themeModeKey = 'theme_mode';

  // Durations
  static const apiTimeout = Duration(seconds: 30);
  static const snackBarDuration = Duration(seconds: 3);
  static const animationDuration = Duration(milliseconds: 300);

  // Constraints
  static const minPasswordLength = 6;
  static const maxRetries = 3;
}

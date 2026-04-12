import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract class AppLogger {
  void debug(String message, {String? tag});
  void info(String message, {String? tag});
  void warning(String message, {String? tag, Object? error});
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  });
}

class DefaultLogger implements AppLogger {
  const DefaultLogger();

  @override
  void debug(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'DEBUG');
    }
  }

  @override
  void info(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'INFO');
    }
  }

  @override
  void warning(String message, {String? tag, Object? error}) {
    developer.log(message, name: tag ?? 'WARNING', error: error);
  }

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

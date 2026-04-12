import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inksight/core/errors/failures.dart';

extension AsyncValueUI on AsyncValue<void> {
  void showErrorSnackBar(BuildContext context) {
    if (hasError) {
      final message = switch (error) {
        final AppFailure failure => failure.message,
        _ => 'An unexpected error occurred.',
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

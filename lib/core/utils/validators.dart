abstract final class Validators {
  static final _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.email_required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'validation.email_invalid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.password_required';
    }
    if (value.length < 6) {
      return 'validation.password_too_short';
    }
    return null;
  }

  static String? notEmpty(String? value, {String? fieldKey}) {
    if (value == null || value.trim().isEmpty) {
      return fieldKey ?? 'validation.field_required';
    }
    return null;
  }
}

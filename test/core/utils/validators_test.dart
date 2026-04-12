import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns error key when null', () {
      expect(Validators.email(null), 'validation.email_required');
    });

    test('returns error key when empty', () {
      expect(Validators.email(''), 'validation.email_required');
    });

    test('returns error key when whitespace only', () {
      expect(Validators.email('   '), 'validation.email_required');
    });

    test('returns error key for invalid email', () {
      expect(Validators.email('notanemail'), 'validation.email_invalid');
      expect(Validators.email('no@'), 'validation.email_invalid');
      expect(Validators.email('@domain.com'), 'validation.email_invalid');
      expect(
        Validators.email('no spaces@mail.com'),
        'validation.email_invalid',
      );
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('test.user@domain.co'), isNull);
      expect(Validators.email('a@b.cd'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error key when null', () {
      expect(Validators.password(null), 'validation.password_required');
    });

    test('returns error key when empty', () {
      expect(Validators.password(''), 'validation.password_required');
    });

    test('returns error key when too short', () {
      expect(Validators.password('12345'), 'validation.password_too_short');
      expect(Validators.password('a'), 'validation.password_too_short');
    });

    test('returns null for valid password', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('strongPassword!'), isNull);
    });
  });

  group('Validators.notEmpty', () {
    test('returns default key when null', () {
      expect(Validators.notEmpty(null), 'validation.field_required');
    });

    test('returns default key when empty', () {
      expect(Validators.notEmpty(''), 'validation.field_required');
    });

    test('returns custom key when provided', () {
      expect(
        Validators.notEmpty('', fieldKey: 'custom.key'),
        'custom.key',
      );
    });

    test('returns null for non-empty value', () {
      expect(Validators.notEmpty('hello'), isNull);
    });
  });
}

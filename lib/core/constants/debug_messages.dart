/// Developer-facing debug messages for `AppFailure` subclasses.
/// These are NOT shown to users — the presentation layer maps
/// failures to localized strings via `FailureMapper`.
abstract final class DebugMessages {
  // Auth
  static const invalidCredentials = 'Invalid email or password.';
  static const emailInUse = 'This email is already in use.';
  static const weakPassword = 'The password is too weak.';
  static const sessionExpired =
      'Session expired. Please sign in again.';
  static const authUnknown =
      'An unknown authentication error occurred.';
  static const authNotConfigured =
      'Auth not configured. Set Supabase credentials in .env.';
  static const signUpNoUser =
      'Sign up succeeded but no user was returned.';

  // Network
  static const noConnection = 'No internet connection.';
  static const serverError = 'Server error. Please try again later.';
  static const timeout = 'Request timed out.';

  // Storage
  static const storageRead = 'Failed to read from storage.';
  static const storageWrite = 'Failed to write to storage.';
}

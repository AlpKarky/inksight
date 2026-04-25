import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnv {
  static String get environment => dotenv.env['ENV'] ?? 'dev';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';
}

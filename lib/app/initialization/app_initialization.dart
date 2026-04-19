import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Binding, locale data, and localization assets required before [runApp].
Future<void> initializeAppShell() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    initializeDateFormatting('en'),
    initializeDateFormatting('es'),
    initializeDateFormatting('fr'),
  ]);

  await EasyLocalization.ensureInitialized();
}

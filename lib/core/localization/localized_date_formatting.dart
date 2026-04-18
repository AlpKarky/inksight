import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension LocalizedDateFormatting on BuildContext {
  /// Short date + time (history cards, analysis result header).
  String formatAnalysisDateTime(DateTime date) =>
      DateFormat.yMMMd(locale.toString()).add_jm().format(date);

  /// Long date (e.g. member since on Settings).
  String formatLongDate(DateTime date) =>
      DateFormat.yMMMMd(locale.toString()).format(date);
}

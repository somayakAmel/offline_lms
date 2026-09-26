import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

extension LocaleExtension on String {
  String tr(BuildContext context) =>
      AppLocalizations.of(context)?.translate(this) ??
      (kReleaseMode ? this : 'Error : not found $this');

  /// Picks `<key>.<form>` for [count] using the locale's plural rules
  /// (Arabic: zero/one/two/few/many/other), falling back to `<key>.other`,
  /// and replaces `{count}`.
  String trPlural(BuildContext context, int count) {
    final localizations = AppLocalizations.of(context);
    final form = Intl.pluralLogic(
      count,
      locale: Localizations.localeOf(context).languageCode,
      zero: 'zero',
      one: 'one',
      two: 'two',
      few: 'few',
      many: 'many',
      other: 'other',
    );
    final text = localizations?.translate('$this.$form') ??
        localizations?.translate('$this.other') ??
        (kReleaseMode ? this : 'Error : not found $this');
    return text.replaceAll('{count}', '$count');
  }
}

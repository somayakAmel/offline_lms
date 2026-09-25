import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// Holds the current app locale and persists the user's choice.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController(this._prefs) : super(_savedLocale(_prefs));

  final SharedPreferences _prefs;

  static const String _key = 'locale';

  static Locale _savedLocale(SharedPreferences prefs) {
    final code = prefs.getString(_key);
    return AppLocalizations.supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => AppLocalizations.supportedLocales.first,
    );
  }

  Future<void> changeLocale(Locale locale) async {
    value = locale;
    await _prefs.setString(_key, locale.languageCode);
  }
}

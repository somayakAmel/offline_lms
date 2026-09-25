import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../core/localization/l10n/app_localizations.dart';
import '../core/localization/l10n/locale_controller.dart';
import '../core/localization/l10n/strings_manager.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: sl<LocaleController>(),
      builder: (context, locale, _) => MaterialApp.router(
        title: StringsManager.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}

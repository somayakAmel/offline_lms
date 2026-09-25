import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/l10n/locale_controller.dart';

final sl = GetIt.instance;

/// Registers app-wide dependencies. Call once before `runApp`.
Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<LocaleController>(LocaleController(sl()));
}

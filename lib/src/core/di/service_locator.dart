import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/courses/data/datasources/courses_local_data_source.dart';
import '../../features/courses/data/repositories/courses_repository_impl.dart';
import '../../features/courses/domain/repositories/courses_repository.dart';
import '../localization/l10n/locale_controller.dart';

final sl = GetIt.instance;

/// Registers app-wide dependencies. Call once before `runApp`.
Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<LocaleController>(LocaleController(sl()));

  //! Courses
  sl.registerLazySingleton<CoursesLocalDataSource>(
      () => CoursesLocalDataSourceImpl());
  sl.registerLazySingleton<CoursesRepository>(
      () => CoursesRepositoryImpl(sl()));
}

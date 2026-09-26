import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/courses/data/datasources/courses_local_data_source.dart';
import '../../features/courses/data/datasources/progress_local_data_source.dart';
import '../../features/courses/data/repositories/courses_repository_impl.dart';
import '../../features/courses/data/repositories/progress_repository_impl.dart';
import '../../features/courses/domain/repositories/courses_repository.dart';
import '../../features/courses/domain/repositories/progress_repository.dart';
import '../database/app_database.dart';
import '../localization/l10n/locale_controller.dart';

final sl = GetIt.instance;

/// Registers app-wide dependencies. Call once before `runApp`.
Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<Database>(await AppDatabase.open());

  sl.registerSingleton<LocaleController>(LocaleController(sl()));

  //! Courses
  sl.registerLazySingleton<CoursesLocalDataSource>(
      () => CoursesLocalDataSourceImpl());
  sl.registerLazySingleton<CoursesRepository>(
      () => CoursesRepositoryImpl(sl()));

  sl.registerLazySingleton<ProgressLocalDataSource>(
      () => ProgressLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<ProgressRepository>(
      () => ProgressRepositoryImpl(sl()));
}

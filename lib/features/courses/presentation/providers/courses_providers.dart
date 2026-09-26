import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../src/core/di/core_providers.dart';
import '../../data/datasources/courses_local_data_source.dart';
import '../../data/datasources/progress_local_data_source.dart';
import '../../data/repositories/courses_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/repositories/courses_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/progress_service.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>(
  (ref) => CoursesRepositoryImpl(CoursesLocalDataSourceImpl()),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(
    ProgressLocalDataSourceImpl(ref.watch(databaseProvider)),
  ),
);

final progressServiceProvider = Provider<ProgressService>(
  (ref) => const ProgressService(),
);

import '../../domain/entities/course.dart';
import '../../domain/repositories/courses_repository.dart';
import '../datasources/courses_local_data_source.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  CoursesRepositoryImpl(this._localDataSource);

  final CoursesLocalDataSource _localDataSource;

  @override
  Future<List<Course>> getCourses() async {
    final models = await _localDataSource.getCourses();
    return models.map((model) => model.toEntity()).toList(growable: false);
  }
}

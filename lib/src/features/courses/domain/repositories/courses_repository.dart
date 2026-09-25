import '../entities/course.dart';

abstract interface class CoursesRepository {
  Future<List<Course>> getCourses();
}

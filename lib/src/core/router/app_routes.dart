/// Route paths. Kept in core with no screen imports, so features can
/// navigate without depending on the router setup in `app/app_router.dart`.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String courses = '/courses';
  static const String profile = '/profile';

  /// Query parameter selecting a lesson on the course details screen.
  static const String lessonQuery = 'lesson';

  static String courseDetails(String courseId, {String? lessonId}) =>
      Uri(
        path: '$courses/$courseId',
        queryParameters: lessonId == null ? null : {lessonQuery: lessonId},
      ).toString();
}

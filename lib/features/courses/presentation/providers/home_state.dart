import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';

/// Everything the courses home screen shows, already calculated.
class HomeState {
  const HomeState({required this.courses, this.continueWatching});

  final List<CourseOverview> courses;

  /// The last opened lesson, when it was started and not finished.
  final ContinueWatching? continueWatching;
}

class CourseOverview {
  const CourseOverview({required this.course, required this.progress});

  final Course course;

  /// Completed-lessons fraction, from 0 to 1.
  final double progress;

  int get lessonCount => course.lessons.length;
  bool get hasLessons => lessonCount > 0;
  int get percent => (progress * 100).round();
  bool get isCompleted => progress >= 1;
}

class ContinueWatching {
  const ContinueWatching({
    required this.course,
    required this.lesson,
    required this.positionSeconds,
    required this.progress,
  });

  final Course course;
  final Lesson lesson;
  final int positionSeconds;

  /// Watched fraction of the lesson, from 0 to 1.
  final double progress;
}

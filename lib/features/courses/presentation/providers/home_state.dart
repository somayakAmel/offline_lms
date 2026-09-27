import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';

/// Everything the courses home screen shows, already calculated.
class HomeState {
  const HomeState({required this.courses, this.continueWatching});

  final List<CourseOverview> courses;

  /// The last opened lesson, when it was started and not finished.
  final ContinueWatching? continueWatching;

  /// Courses whose title contains [query]; all courses for a blank query.
  List<CourseOverview> coursesMatching(String query) {
    final normalizedQuery = _normalizeForSearch(query);
    if (normalizedQuery.isEmpty) return courses;
    return courses
        .where((overview) =>
            _normalizeForSearch(overview.course.title).contains(normalizedQuery))
        .toList();
  }
}

/// Lower-cased, with Arabic diacritics removed and common letter variants
/// unified (أ/إ/آ → ا, ة → ه, ى → ي), so "مقدمه" finds "مقدمة".
String _normalizeForSearch(String text) => text
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[ً-ْـ]'), '')
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي')
    .replaceAll(RegExp(r'\s+'), ' ');

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

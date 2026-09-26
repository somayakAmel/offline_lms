import '../entities/course.dart';
import '../entities/lesson.dart';
import '../entities/lesson_progress.dart';

/// Learning-progress rules shared by the courses screen and the player.
class ProgressService {
  const ProgressService();

  /// A lesson counts as completed once 90% of it has been watched.
  static const double completionThreshold = 0.9;

  bool isLessonCompleted({
    required int positionSeconds,
    required int durationSeconds,
  }) =>
      durationSeconds > 0 &&
      positionSeconds >= durationSeconds * completionThreshold;

  /// Started but not completed, so it can be resumed.
  bool isLessonInProgress(Lesson lesson, LessonProgress? progress) =>
      progress != null &&
      !progress.completed &&
      progress.watchedPositionSeconds > 0 &&
      !isLessonCompleted(
        positionSeconds: progress.watchedPositionSeconds,
        durationSeconds: lesson.durationSec,
      );

  /// Watched fraction of [lesson] at [positionSeconds], from 0 to 1.
  double lessonProgress(Lesson lesson, int positionSeconds) =>
      lesson.durationSec <= 0
          ? 0
          : (positionSeconds / lesson.durationSec).clamp(0.0, 1.0);

  /// Fraction of [course] lessons that are completed, from 0 to 1.
  double courseProgress(
    Course course,
    Map<String, LessonProgress> progressByLessonId,
  ) {
    final lessons = course.lessons;
    if (lessons.isEmpty) return 0;
    final completed = lessons
        .where((lesson) => progressByLessonId[lesson.id]?.completed ?? false)
        .length;
    return completed / lessons.length;
  }
}

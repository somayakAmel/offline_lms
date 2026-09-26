import '../entities/course.dart';
import '../entities/lesson.dart';
import '../entities/lesson_progress.dart';
import '../entities/lesson_status.dart';

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

  /// Lessons unlock in course order: the first lesson is open, and each
  /// later lesson opens once the one before it is completed.
  bool isLessonUnlocked(
    Course course,
    String lessonId,
    Map<String, LessonProgress> progressByLessonId,
  ) {
    final lessons = course.lessons;
    final index = lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index < 0) return false;
    if (index == 0) return true;
    return progressByLessonId[lessons[index - 1].id]?.completed ?? false;
  }

  LessonStatus lessonStatus(
    Course course,
    Lesson lesson,
    Map<String, LessonProgress> progressByLessonId,
  ) {
    final progress = progressByLessonId[lesson.id];
    if (progress?.completed ?? false) return LessonStatus.completed;
    if (!isLessonUnlocked(course, lesson.id, progressByLessonId)) {
      return LessonStatus.locked;
    }
    if (isLessonInProgress(lesson, progress)) return LessonStatus.inProgress;
    return LessonStatus.available;
  }

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

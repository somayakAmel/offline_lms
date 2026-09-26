import '../entities/lesson_note.dart';
import '../entities/lesson_progress.dart';

abstract interface class ProgressRepository {
  Future<LessonProgress?> getLessonProgress(String lessonId);

  /// Never turns a completed lesson back to not completed.
  Future<void> saveLessonProgress(LessonProgress progress);

  Future<void> deleteLessonProgress(String lessonId);

  Future<LessonNote?> getLessonNote(String lessonId);

  /// Saving a blank note deletes the lesson's note.
  Future<void> saveLessonNote(LessonNote note);

  Future<void> deleteLessonNote(String lessonId);

  Future<String?> getLastOpenedLessonId();

  Future<void> saveLastOpenedLessonId(String lessonId);
}

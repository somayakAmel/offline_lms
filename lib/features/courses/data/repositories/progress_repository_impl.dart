import '../../domain/entities/lesson_note.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_data_source.dart';
import '../models/lesson_note_model.dart';
import '../models/lesson_progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._localDataSource);

  final ProgressLocalDataSource _localDataSource;

  @override
  Future<List<LessonProgress>> getAllLessonProgress() async =>
      (await _localDataSource.getAllLessonProgress())
          .map((model) => model.toEntity())
          .toList(growable: false);

  @override
  Future<LessonProgress?> getLessonProgress(String lessonId) async =>
      (await _localDataSource.getLessonProgress(lessonId))?.toEntity();

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {
    final existing = await _localDataSource.getLessonProgress(progress.lessonId);
    final completed = progress.completed || (existing?.completed ?? false);
    await _localDataSource.saveLessonProgress(LessonProgressModel(
      lessonId: progress.lessonId,
      watchedPositionSeconds: progress.watchedPositionSeconds,
      completed: completed,
      updatedAt: progress.updatedAt,
    ));
  }

  @override
  Future<void> deleteLessonProgress(String lessonId) =>
      _localDataSource.deleteLessonProgress(lessonId);

  @override
  Future<LessonNote?> getLessonNote(String lessonId) async =>
      (await _localDataSource.getLessonNote(lessonId))?.toEntity();

  @override
  Future<void> saveLessonNote(LessonNote note) {
    if (note.content.trim().isEmpty) {
      return _localDataSource.deleteLessonNote(note.lessonId);
    }
    return _localDataSource.saveLessonNote(LessonNoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteLessonNote(String lessonId) =>
      _localDataSource.deleteLessonNote(lessonId);

  @override
  Future<Set<String>> getLessonIdsWithNotes() =>
      _localDataSource.getLessonIdsWithNotes();

  @override
  Future<String?> getLastOpenedLessonId() =>
      _localDataSource.getLastOpenedLessonId();

  @override
  Future<void> saveLastOpenedLessonId(String lessonId) =>
      _localDataSource.saveLastOpenedLessonId(lessonId);
}

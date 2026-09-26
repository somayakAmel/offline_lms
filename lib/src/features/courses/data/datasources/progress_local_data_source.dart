import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/lesson_note_model.dart';
import '../models/lesson_progress_model.dart';

abstract interface class ProgressLocalDataSource {
  Future<LessonProgressModel?> getLessonProgress(String lessonId);

  Future<void> saveLessonProgress(LessonProgressModel progress);

  Future<void> deleteLessonProgress(String lessonId);

  Future<LessonNoteModel?> getLessonNote(String lessonId);

  Future<void> saveLessonNote(LessonNoteModel note);

  Future<void> deleteLessonNote(String lessonId);

  Future<String?> getLastOpenedLessonId();

  Future<void> saveLastOpenedLessonId(String lessonId);
}

/// Stores lesson progress, notes and the last opened lesson in SQLite.
/// Saves are upserts keyed by `lesson_id` (or `key` for app state).
class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  ProgressLocalDataSourceImpl(this._db);

  final Database _db;

  static const String _lastOpenedLessonKey = 'last_opened_lesson_id';

  @override
  Future<LessonProgressModel?> getLessonProgress(String lessonId) async {
    final rows = await _db.query(
      AppDatabase.lessonProgressTable,
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      limit: 1,
    );
    return rows.isEmpty ? null : LessonProgressModel.fromMap(rows.first);
  }

  @override
  Future<void> saveLessonProgress(LessonProgressModel progress) =>
      _db.insert(
        AppDatabase.lessonProgressTable,
        progress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  @override
  Future<void> deleteLessonProgress(String lessonId) => _db.delete(
        AppDatabase.lessonProgressTable,
        where: 'lesson_id = ?',
        whereArgs: [lessonId],
      );

  @override
  Future<LessonNoteModel?> getLessonNote(String lessonId) async {
    final rows = await _db.query(
      AppDatabase.lessonNotesTable,
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      limit: 1,
    );
    return rows.isEmpty ? null : LessonNoteModel.fromMap(rows.first);
  }

  @override
  Future<void> saveLessonNote(LessonNoteModel note) => _db.insert(
        AppDatabase.lessonNotesTable,
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  @override
  Future<void> deleteLessonNote(String lessonId) => _db.delete(
        AppDatabase.lessonNotesTable,
        where: 'lesson_id = ?',
        whereArgs: [lessonId],
      );

  @override
  Future<String?> getLastOpenedLessonId() async {
    final rows = await _db.query(
      AppDatabase.appStateTable,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_lastOpenedLessonKey],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  @override
  Future<void> saveLastOpenedLessonId(String lessonId) => _db.insert(
        AppDatabase.appStateTable,
        {'key': _lastOpenedLessonKey, 'value': lessonId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
}

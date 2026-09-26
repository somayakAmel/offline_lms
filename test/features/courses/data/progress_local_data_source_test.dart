import 'package:flutter_test/flutter_test.dart';
import 'package:offline_lms/src/core/database/app_database.dart';
import 'package:offline_lms/src/features/courses/data/datasources/progress_local_data_source.dart';
import 'package:offline_lms/src/features/courses/data/models/lesson_note_model.dart';
import 'package:offline_lms/src/features/courses/data/models/lesson_progress_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late ProgressLocalDataSource dataSource;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    dataSource = ProgressLocalDataSourceImpl(db);
  });

  tearDown(() => db.close());

  Future<int> rowCount(String table) async => (await db.query(table)).length;

  group('lesson progress', () {
    final progress = LessonProgressModel(
      lessonId: 'anatomy-s1-l1',
      watchedPositionSeconds: 12,
      completed: false,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
    );

    test('returns null when nothing was saved', () async {
      expect(await dataSource.getLessonProgress('anatomy-s1-l1'), isNull);
    });

    test('save then get preserves the values', () async {
      await dataSource.saveLessonProgress(progress);

      final saved = await dataSource.getLessonProgress('anatomy-s1-l1');
      expect(saved!.lessonId, 'anatomy-s1-l1');
      expect(saved.watchedPositionSeconds, 12);
      expect(saved.completed, isFalse);
      expect(saved.updatedAt, DateTime.fromMillisecondsSinceEpoch(1000));
    });

    test('saving the same lesson again updates it without a duplicate',
        () async {
      await dataSource.saveLessonProgress(progress);
      await dataSource.saveLessonProgress(LessonProgressModel(
        lessonId: 'anatomy-s1-l1',
        watchedPositionSeconds: 28,
        completed: true,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
      ));

      final saved = await dataSource.getLessonProgress('anatomy-s1-l1');
      expect(saved!.watchedPositionSeconds, 28);
      expect(saved.completed, isTrue);
      expect(await rowCount(AppDatabase.lessonProgressTable), 1);
    });

    test('delete removes the record', () async {
      await dataSource.saveLessonProgress(progress);
      await dataSource.deleteLessonProgress('anatomy-s1-l1');

      expect(await dataSource.getLessonProgress('anatomy-s1-l1'), isNull);
    });
  });

  group('lesson notes', () {
    LessonNoteModel note(String content) => LessonNoteModel(
          lessonId: 'anatomy-s1-l1',
          content: content,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
        );

    test('save then get returns the content', () async {
      await dataSource.saveLessonNote(note('العظام الطويلة'));

      final saved = await dataSource.getLessonNote('anatomy-s1-l1');
      expect(saved!.content, 'العظام الطويلة');
    });

    test('saving again updates the existing note', () async {
      await dataSource.saveLessonNote(note('first'));
      await dataSource.saveLessonNote(note('second'));

      expect((await dataSource.getLessonNote('anatomy-s1-l1'))!.content,
          'second');
      expect(await rowCount(AppDatabase.lessonNotesTable), 1);
    });

    test('delete removes the note', () async {
      await dataSource.saveLessonNote(note('first'));
      await dataSource.deleteLessonNote('anatomy-s1-l1');

      expect(await dataSource.getLessonNote('anatomy-s1-l1'), isNull);
    });
  });

  group('last opened lesson', () {
    test('returns null when nothing was saved', () async {
      expect(await dataSource.getLastOpenedLessonId(), isNull);
    });

    test('saving replaces the previous value', () async {
      await dataSource.saveLastOpenedLessonId('anatomy-s1-l1');
      expect(await dataSource.getLastOpenedLessonId(), 'anatomy-s1-l1');

      await dataSource.saveLastOpenedLessonId('physiology-s2-l3');
      expect(await dataSource.getLastOpenedLessonId(), 'physiology-s2-l3');
      expect(await rowCount(AppDatabase.appStateTable), 1);
    });
  });
}

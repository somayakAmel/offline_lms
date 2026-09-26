import 'package:flutter_test/flutter_test.dart';
import 'package:offline_lms/src/core/database/app_database.dart';
import 'package:offline_lms/src/features/courses/data/datasources/progress_local_data_source.dart';
import 'package:offline_lms/src/features/courses/data/repositories/progress_repository_impl.dart';
import 'package:offline_lms/src/features/courses/domain/entities/lesson_note.dart';
import 'package:offline_lms/src/features/courses/domain/entities/lesson_progress.dart';
import 'package:offline_lms/src/features/courses/domain/repositories/progress_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late ProgressRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = ProgressRepositoryImpl(ProgressLocalDataSourceImpl(db));
  });

  tearDown(() => db.close());

  LessonProgress progress(int position, {required bool completed}) =>
      LessonProgress(
        lessonId: 'anatomy-s1-l1',
        watchedPositionSeconds: position,
        completed: completed,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(position * 1000),
      );

  test('a completed lesson stays completed when a smaller position is saved',
      () async {
    await repository.saveLessonProgress(progress(28, completed: true));
    await repository.saveLessonProgress(progress(5, completed: false));

    final saved = await repository.getLessonProgress('anatomy-s1-l1');
    expect(saved!.completed, isTrue);
    expect(saved.watchedPositionSeconds, 5);
  });

  test('a lesson that was not completed can become completed', () async {
    await repository.saveLessonProgress(progress(5, completed: false));
    await repository.saveLessonProgress(progress(28, completed: true));

    expect(
        (await repository.getLessonProgress('anatomy-s1-l1'))!.completed, isTrue);
  });

  test('saving a blank note deletes the existing note', () async {
    LessonNote note(String content) => LessonNote(
          lessonId: 'anatomy-s1-l1',
          content: content,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
        );

    await repository.saveLessonNote(note('العظام الطويلة'));
    await repository.saveLessonNote(note('   '));

    expect(await repository.getLessonNote('anatomy-s1-l1'), isNull);
  });
}

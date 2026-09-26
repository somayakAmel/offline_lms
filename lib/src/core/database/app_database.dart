import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the local SQLite database that holds mutable user state
/// (lesson progress, notes, app state). Course content stays in the
/// bundled `courses.json`.
class AppDatabase {
  AppDatabase._();

  static const String _name = 'offline_lms.db';

  /// Bump when the schema changes and add an `onUpgrade` migration.
  static const int _version = 1;

  static const String lessonProgressTable = 'lesson_progress';
  static const String lessonNotesTable = 'lesson_notes';
  static const String appStateTable = 'app_state';

  /// [factory] and [path] let tests use an in-memory database.
  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? join(await dbFactory.getDatabasesPath(), _name);
    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: _version, onCreate: _onCreate),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE $lessonProgressTable (
          lesson_id TEXT PRIMARY KEY,
          watched_position_seconds INTEGER NOT NULL,
          completed INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )''')
      ..execute('''
        CREATE TABLE $lessonNotesTable (
          lesson_id TEXT PRIMARY KEY,
          content TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        )''')
      ..execute('''
        CREATE TABLE $appStateTable (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )''');
    await batch.commit(noResult: true);
  }
}

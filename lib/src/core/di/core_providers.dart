import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Opened once in `bootstrap` and provided through `ProviderScope.overrides`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in bootstrap'),
);

/// Opened once in `bootstrap` and provided through `ProviderScope.overrides`.
final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('Override in bootstrap'),
);

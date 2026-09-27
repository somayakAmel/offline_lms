import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/courses_providers.dart';
import '../../domain/entities/lesson_note.dart';

/// Ids of the lessons that have a saved note, for the note icons.
/// Refreshed only when a note is saved or deleted.
final lessonIdsWithNotesProvider = FutureProvider.autoDispose<Set<String>>(
  (ref) => ref.watch(progressRepositoryProvider).getLessonIdsWithNotes(),
  retry: (_, _) => null,
);

/// One lesson's note (`null` when it has none), keyed by lesson id.
final lessonNoteProvider = AsyncNotifierProvider.autoDispose
    .family<LessonNoteNotifier, LessonNote?, String>(
      LessonNoteNotifier.new,
      retry: (_, _) => null,
    );

class LessonNoteNotifier extends AsyncNotifier<LessonNote?> {
  LessonNoteNotifier(this.lessonId);

  final String lessonId;

  @override
  Future<LessonNote?> build() =>
      ref.read(progressRepositoryProvider).getLessonNote(lessonId);

  /// Saves [content]; blank content deletes the note (repository rule).
  /// Returns whether a note exists afterwards. Throws if storage fails.
  Future<bool> save(String content) async {
    final note = LessonNote(
      lessonId: lessonId,
      content: content,
      updatedAt: DateTime.now(),
    );
    await ref.read(progressRepositoryProvider).saveLessonNote(note);
    final exists = content.trim().isNotEmpty;
    // The sheet keeps this provider alive until the save finishes.
    if (ref.mounted) {
      state = AsyncData(exists ? note : null);
      ref.invalidate(lessonIdsWithNotesProvider);
    }
    return exists;
  }
}

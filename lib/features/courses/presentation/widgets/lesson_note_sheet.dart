import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_note.dart';
import '../providers/lesson_notes_provider.dart';

enum LessonNoteResult { saved, deleted }

/// Opens the note editor for [lesson] above the current screen. Resolves
/// with what was saved, or `null` if the sheet was closed without saving.
///
/// Dragging is off: a drag closes the sheet without asking, and unsaved
/// changes must go through the discard confirmation.
Future<LessonNoteResult?> showLessonNoteSheet(
  BuildContext context,
  Lesson lesson,
) => showModalBottomSheet<LessonNoteResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  enableDrag: false,
  builder: (context) => LessonNoteSheet(lesson: lesson),
);

class LessonNoteSheet extends ConsumerStatefulWidget {
  const LessonNoteSheet({super.key, required this.lesson});

  final Lesson lesson;

  @override
  ConsumerState<LessonNoteSheet> createState() => _LessonNoteSheetState();
}

class _LessonNoteSheetState extends ConsumerState<LessonNoteSheet> {
  /// Created once the saved note has loaded.
  TextEditingController? _text;
  LessonNote? _original;
  bool _saving = false;
  bool _saveFailed = false;

  String get _originalContent => _original?.content ?? '';

  bool get _dirty => _text != null && _text!.text != _originalContent;

  /// Clearing an existing note turns Save into Delete.
  bool get _deletes => _original != null && _text!.text.trim().isEmpty;

  /// Nothing to save: unchanged, or empty with no note to delete.
  bool get _canSave =>
      !_saving &&
      _dirty &&
      (_text!.text.trim().isNotEmpty || _original != null);

  void _startEditing(LessonNote? note) {
    _original = note;
    _text = TextEditingController(text: note?.content ?? '')
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      final exists = await ref
          .read(lessonNoteProvider(widget.lesson.id).notifier)
          .save(_text!.text);
      if (!mounted) return;
      Navigator.of(context)
          .pop(exists ? LessonNoteResult.saved : LessonNoteResult.deleted);
    } catch (_) {
      if (!mounted) return;
      // Shown in the sheet: a snackbar would sit behind it.
      setState(() {
        _saving = false;
        _saveFailed = true;
      });
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        // The pale primary is hard to read as text on the light dialog.
        final buttonStyle =
            TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface);
        return AlertDialog(
          title: Text(StringsManager.discardChangesTitle.tr(context)),
          titleTextStyle: theme.textTheme.titleMedium,
          content: Text(StringsManager.discardChangesMessage.tr(context)),
          contentTextStyle:
              theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
          actions: [
            TextButton(
              style: buttonStyle,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(StringsManager.keepEditing.tr(context)),
            ),
            TextButton(
              style: buttonStyle,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(StringsManager.discard.tr(context)),
            ),
          ],
        );
      },
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = ref.watch(lessonNoteProvider(widget.lesson.id));
    if (_text == null && note.hasValue && !note.isLoading) {
      _startEditing(note.value);
    }

    final Widget body;
    if (_text != null) {
      body = _editor(theme);
    } else if (note.hasError && !note.isLoading) {
      body = _LoadError(
        onRetry: () => ref.invalidate(lessonNoteProvider(widget.lesson.id)),
      );
    } else {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Back and taps outside the sheet ask first when there are unsaved
    // changes, and wait while saving; Save and Discard close it directly.
    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_saving) _confirmDiscard();
      },
      child: Padding(
        // Keeps the sheet above the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringsManager.lessonNotes.tr(context),
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          widget.lesson.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    // maybePop, so unsaved changes are confirmed.
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(child: body),
          ],
        ),
      ),
    );
  }

  Widget _editor(ThemeData theme) {
    final scheme = theme.colorScheme;
    final original = _original;
    final String? info = _saveFailed
        ? StringsManager.noteSaveError.tr(context)
        : _deletes
        ? StringsManager.emptyNoteDeletes.tr(context)
        : original == null
        ? null
        : StringsManager.noteLastEdited
              .tr(context)
              .replaceAll('{date}', _formatDate(original.updatedAt));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _text,
            autofocus: true,
            enabled: !_saving,
            minLines: 5,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: StringsManager.noteHint.tr(context),
              border: const OutlineInputBorder(),
            ),
          ),
          if (info != null) ...[
            const SizedBox(height: 8),
            Text(
              info,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _saveFailed || _deletes ? scheme.error : null,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _canSave ? _save : null,
            style: _deletes
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : FilledButton.styleFrom(
                    backgroundColor: scheme.secondary,
                    foregroundColor: scheme.onSecondary,
                  ),
            child: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    (_deletes ? StringsManager.deleteNote : StringsManager.save)
                        .tr(context),
                  ),
          ),
        ],
      ),
    );
  }

  /// Date and time in the app's language, via the material localizations.
  String _formatDate(DateTime date) {
    final localizations = MaterialLocalizations.of(context);
    final local = date.toLocal();
    return '${localizations.formatMediumDate(local)} '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringsManager.noteLoadError.tr(context),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(StringsManager.retry.tr(context)),
          ),
        ],
      ),
    );
  }
}

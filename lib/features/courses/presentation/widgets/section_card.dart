import 'package:flutter/material.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/functions/duration_format.dart';
import '../../domain/entities/lesson_status.dart';
import '../providers/course_details_state.dart';

/// A course section with its lessons; the header collapses the list.
class SectionCard extends StatefulWidget {
  const SectionCard({
    super.key,
    required this.item,
    required this.selectedLessonId,
    required this.onLessonTap,
    required this.onNotesTap,
  });

  final SectionItem item;
  final String? selectedLessonId;
  final ValueChanged<LessonItem> onLessonTap;
  final ValueChanged<LessonItem> onNotesTap;

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final section = widget.item.section;
    final radius = BorderRadius.circular(12);

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          '${StringsManager.lessons.trPlural(context, section.lessons.length)}'
                          '  •  '
                          '${formatDuration(section.totalDurationSec)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded,
                        color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    children: [
                      Divider(height: 1, color: scheme.outlineVariant),
                      for (final lesson in widget.item.lessons)
                        _LessonTile(
                          item: lesson,
                          selected: lesson.lesson.id == widget.selectedLessonId,
                          onTap: () => widget.onLessonTap(lesson),
                          onNotesTap: () => widget.onNotesTap(lesson),
                        ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onNotesTap,
  });

  final LessonItem item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onNotesTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final small = theme.textTheme.bodySmall;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.55)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 4, 10),
          child: Row(
            children: [
              _StatusBadge(status: item.status, selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.lesson.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: item.isLocked
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(formatDuration(item.lesson.durationSec),
                            style: small),
                        if (item.status == LessonStatus.inProgress)
                          Text('  •  ${(item.progress * 100).round()}%',
                              style: small),
                        if (item.status == LessonStatus.completed)
                          Text(
                            '  •  ${StringsManager.lessonCompleted.tr(context)}',
                            style: small?.copyWith(
                                color: scheme.secondary,
                                fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNotesTap,
                tooltip: StringsManager.lessonNotes.tr(context),
                icon: Icon(Icons.edit_note_rounded,
                    color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.selected});

  final LessonStatus status;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, Color background, Color foreground) = switch (status) {
      LessonStatus.locked => (
          Icons.lock_rounded,
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
      LessonStatus.completed => (
          Icons.check_rounded,
          scheme.secondary.withValues(alpha: 0.14),
          scheme.secondary,
        ),
      _ when selected => (
          Icons.play_arrow_rounded,
          scheme.secondary,
          scheme.onSecondary,
        ),
      _ => (
          Icons.play_arrow_rounded,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
    };
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: foreground),
    );
  }
}

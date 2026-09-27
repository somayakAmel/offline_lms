import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/router/app_routes.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_status.dart';
import '../providers/course_details_provider.dart';
import '../providers/course_details_state.dart';
import '../providers/home_notifier.dart';
import '../providers/lesson_notes_provider.dart';
import '../providers/lesson_player_provider.dart';
import '../widgets/course_media_area.dart';
import '../widgets/course_progress_bar.dart';
import '../widgets/course_stats_row.dart';
import '../widgets/lesson_note_sheet.dart';
import '../widgets/status_views.dart';
import '../widgets/section_card.dart';

class CourseDetailsPage extends ConsumerStatefulWidget {
  const CourseDetailsPage({
    super.key,
    required this.courseId,
    this.initialLessonId,
  });

  final String courseId;

  /// Lesson to select on open (e.g. from Continue watching), if unlocked.
  final String? initialLessonId;

  /// Page content is at most this wide, centred on tablets.
  static const double maxWidth = 720;

  @override
  ConsumerState<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends ConsumerState<CourseDetailsPage> {
  late String? _selectedLessonId = widget.initialLessonId;
  bool _leaving = false;

  /// Saves the current lesson's position, refreshes Home (progress and
  /// Continue watching), then leaves.
  Future<void> _goBack() async {
    if (_leaving) return;
    _leaving = true;
    final lessonId = _selectedLessonId;
    if (lessonId != null && ref.exists(lessonPlayerProvider(lessonId))) {
      await ref.read(lessonPlayerProvider(lessonId).notifier).save();
    }
    if (!mounted) return;
    ref.invalidate(homeProvider);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.courses);
    }
  }

  void _onLessonTap(LessonItem item) {
    if (item.isLocked) {
      _showMessage(StringsManager.lessonLocked);
      return;
    }
    _select(item.lesson.id);
  }

  /// The previous lesson's player is disposed (paused and saved) as soon as
  /// nothing shows it.
  void _select(String lessonId) => setState(() => _selectedLessonId = lessonId);

  /// Notes are only for unlocked lessons. The sheet opens above this page,
  /// so the player stays mounted and keeps its position.
  Future<void> _onNotesTap(LessonItem item) async {
    if (item.isLocked) return;
    final result = await showLessonNoteSheet(context, item.lesson);
    if (!mounted || result == null) return;
    _showMessage(switch (result) {
      LessonNoteResult.saved => StringsManager.noteSaved,
      LessonNoteResult.deleted => StringsManager.noteDeleted,
    });
  }

  void _showMessage(String key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(key.tr(context))));
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(courseDetailsProvider(widget.courseId));

    // Each save of the playing lesson refreshes statuses and progress, so a
    // lesson reaching 90% unlocks the next one right away.
    final playingId = _selectedLessonId;
    if (playingId != null) {
      ref.listen(
        lessonPlayerProvider(playingId)
            .select((player) => player.value?.savedPositionSeconds),
        (_, _) => ref.invalidate(courseDetailsProvider(widget.courseId)),
      );
      ref.listen(
        lessonPlayerProvider(playingId)
            .select((player) => player.value?.completed),
        (_, _) => ref.invalidate(courseDetailsProvider(widget.courseId)),
      );
    }

    final Widget body;
    if (details.hasValue && details.value != null) {
      body = _content(details.requireValue!);
    } else if (details.isLoading) {
      body = _statusLayout(const Center(child: CircularProgressIndicator()));
    } else if (details.hasError) {
      body = _statusLayout(
        Center(
          child: CoursesErrorView(
            onRetry: () =>
                ref.invalidate(courseDetailsProvider(widget.courseId)),
          ),
        ),
      );
    } else {
      body = _statusLayout(Center(child: CourseNotFoundView(onBack: _goBack)));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(body: body),
    );
  }

  /// Loading, error and not found: a plain back button above the message.
  Widget _statusLayout(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  onPressed: _goBack,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _content(CourseDetailsState state) {
    final selected = _selectedLessonId == null
        ? null
        : state.lessonById(_selectedLessonId!);
    final selectedLesson = selected == null || selected.isLocked
        ? null
        : selected.lesson;
    final sectionsWithLessons = state.sections.where(
      (item) => item.lessons.isNotEmpty,
    );

    final topInset = MediaQuery.paddingOf(context).top;

    // The image or video is the top of the screen: it runs behind the
    // status bar (light icons) with the back button floating on it. It
    // spans the full width; the rest is centred on tablets.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
        children: [
          Stack(
            children: [
              CourseMediaArea(
                course: state.course,
                lesson: selectedLesson,
                topInset: topInset,
              ),
              PositionedDirectional(
                top: topInset + 8,
                start: 12,
                child: IconButton(
                  onPressed: _goBack,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.35),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: CourseDetailsPage.maxWidth,
                ),
                child: _details(
                  state,
                  selected,
                  selectedLesson,
                  sectionsWithLessons.toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(
    CourseDetailsState state,
    LessonItem? selected,
    Lesson? selectedLesson,
    List<SectionItem> sectionsWithLessons,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (selected != null && !selected.isLocked)
          _NowPlayingBar(
            current: selected,
            next: state.nextAfter(selected.lesson.id),
            onNext: _select,
          ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              Text(
                state.course.title,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(state.course.instructor, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              CourseStatsRow(
                sectionCount: state.sectionCount,
                lessonCount: state.lessonCount,
                totalDurationSec: state.totalDurationSec,
              ),
              if (state.hasLessons) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        StringsManager.yourProgress.tr(context),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${state.percent}%',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CourseProgressBar(value: state.progress),
                const SizedBox(height: 28),
                Semantics(
                  header: true,
                  child: Text(
                    StringsManager.courseContent.tr(context),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                for (final (index, section) in sectionsWithLessons.indexed) ...[
                  if (index > 0) const SizedBox(height: 12),
                  // Only the cards rebuild when a note is saved or deleted.
                  Consumer(
                    builder: (context, ref, _) => SectionCard(
                      item: section,
                      selectedLessonId: selectedLesson?.id,
                      onLessonTap: _onLessonTap,
                      onNotesTap: _onNotesTap,
                      lessonIdsWithNotes:
                          ref.watch(lessonIdsWithNotesProvider).value ??
                          const {},
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 24),
                const CourseNoLessonsView(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Under the player: the current lesson, and what comes next.
class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({
    required this.current,
    required this.next,
    required this.onNext,
  });

  final LessonItem current;

  /// The following lesson in course order; `null` for the last lesson.
  final LessonItem? next;
  final ValueChanged<String> onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final completed = current.status == LessonStatus.completed;
    final next = this.next;

    final Widget? trailing;
    final String? hint;
    if (next != null && !next.isLocked) {
      trailing = FilledButton.icon(
        onPressed: () => onNext(next.lesson.id),
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
        ),
        // Mirrors in RTL, so it points left: "forward".
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        label: Text(StringsManager.nextLesson.tr(context)),
      );
      hint = null;
    } else {
      trailing = null;
      hint = next != null
          ? StringsManager.unlockNextHint.tr(context)
          : completed
          ? StringsManager.courseFinished.tr(context)
          : null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  current.lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                if (completed)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: scheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        StringsManager.lessonCompletedBanner.tr(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                if (hint != null) Text(hint, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );
  }
}

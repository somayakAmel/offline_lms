import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/router/app_routes.dart';
import '../providers/course_details_provider.dart';
import '../providers/course_details_state.dart';
import '../widgets/course_media_area.dart';
import '../widgets/course_progress_bar.dart';
import '../widgets/course_stats_row.dart';
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

  void _goBack() {
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
    setState(() => _selectedLessonId = item.lesson.id);
  }

  // Notes are added in a later step.
  void _onNotesTap(LessonItem item) =>
      _showMessage(StringsManager.notesUnavailable);

  void _showMessage(String key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(key.tr(context))));
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(courseDetailsProvider(widget.courseId));

    final Widget body;
    if (details.hasValue && details.value != null) {
      body = _content(details.requireValue!);
    } else if (details.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (details.hasError) {
      body = Center(
        child: CoursesErrorView(
          onRetry: () =>
              ref.invalidate(courseDetailsProvider(widget.courseId)),
        ),
      );
    } else {
      body = Center(child: CourseNotFoundView(onBack: _goBack));
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: CourseDetailsPage.maxWidth),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget _content(CourseDetailsState state) {
    final theme = Theme.of(context);
    final selected = _selectedLessonId == null
        ? null
        : state.lessonById(_selectedLessonId!);
    final selectedLesson =
        selected == null || selected.isLocked ? null : selected.lesson;
    final sectionsWithLessons =
        state.sections.where((item) => item.lessons.isNotEmpty);

    return Column(
      children: [
        Stack(
          children: [
            CourseMediaArea(course: state.course, lesson: selectedLesson),
            PositionedDirectional(
              top: 8,
              start: 8,
              child: IconButton.filledTonal(
                onPressed: _goBack,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerLowest
                      .withValues(alpha: 0.9),
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, 24 + MediaQuery.paddingOf(context).bottom),
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
                      child: Text(StringsManager.yourProgress.tr(context),
                          style: theme.textTheme.bodyMedium),
                    ),
                    Text('${state.percent}%',
                        style: theme.textTheme.labelLarge),
                  ],
                ),
                const SizedBox(height: 8),
                CourseProgressBar(value: state.progress),
                const SizedBox(height: 28),
                Semantics(
                  header: true,
                  child: Text(StringsManager.courseContent.tr(context),
                      style: theme.textTheme.titleLarge),
                ),
                const SizedBox(height: 12),
                for (final (index, section) in sectionsWithLessons.indexed) ...[
                  if (index > 0) const SizedBox(height: 12),
                  SectionCard(
                    item: section,
                    selectedLessonId: selectedLesson?.id,
                    onLessonTap: _onLessonTap,
                    onNotesTap: _onNotesTap,
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

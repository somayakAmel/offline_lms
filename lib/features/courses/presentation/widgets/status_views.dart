import 'package:flutter/material.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';

/// Static placeholders shaped like the course cards while data loads.
class CoursesLoadingView extends StatelessWidget {
  const CoursesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget block(double width, double height, {double radius = 6}) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    Widget card() => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  block(104, 78, radius: 12),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        block(160, 14),
                        const SizedBox(height: 10),
                        block(100, 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              block(double.infinity, 6),
            ],
          ),
        );

    return ExcludeSemantics(
      child: Column(
        children: [card(), const SizedBox(height: 12), card()],
      ),
    );
  }
}

class CoursesEmptyView extends StatelessWidget {
  const CoursesEmptyView({super.key});

  @override
  Widget build(BuildContext context) => _MessageView(
        icon: Icons.menu_book_outlined,
        title: StringsManager.noCoursesTitle.tr(context),
        message: StringsManager.noCoursesMessage.tr(context),
      );
}

class CoursesErrorView extends StatelessWidget {
  const CoursesErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _MessageView(
        icon: Icons.error_outline_rounded,
        title: StringsManager.coursesLoadErrorTitle.tr(context),
        message: StringsManager.coursesLoadErrorMessage.tr(context),
        action: FilledButton.tonalIcon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: Text(StringsManager.retry.tr(context)),
        ),
      );
}

/// Course details: the course has no lessons (no sections, or empty ones).
class CourseNoLessonsView extends StatelessWidget {
  const CourseNoLessonsView({super.key});

  @override
  Widget build(BuildContext context) => _MessageView(
        icon: Icons.video_library_outlined,
        title: StringsManager.noLessonsTitle.tr(context),
        message: StringsManager.noLessonsMessage.tr(context),
      );
}

/// Course details: the course id is not in the catalog.
class CourseNotFoundView extends StatelessWidget {
  const CourseNotFoundView({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => _MessageView(
        icon: Icons.search_off_rounded,
        title: StringsManager.courseNotFoundTitle.tr(context),
        message: StringsManager.courseNotFoundMessage.tr(context),
        action: FilledButton.tonal(
          onPressed: onBack,
          child: Text(StringsManager.backToCourses.tr(context)),
        ),
      );
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

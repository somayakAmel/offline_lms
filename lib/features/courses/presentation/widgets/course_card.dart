import 'package:flutter/material.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../providers/home_state.dart';
import 'course_progress_bar.dart';
import 'course_thumbnail.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.overview, required this.onTap});

  final CourseOverview overview;
  final VoidCallback onTap;

  static const double _thumbnailHeight = 88;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final course = overview.course;
    final radius = BorderRadius.circular(12);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CourseThumbnail(
                      asset: course.thumbnail,
                      width: 112,
                      height: _thumbnailHeight,
                      radius: 10,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course.instructor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          _Metadata(overview: overview),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: _thumbnailHeight,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        // Mirrors in RTL, so it points left: "go forward".
                        child: Icon(Icons.chevron_right_rounded,
                            size: 22, color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                if (overview.hasLessons) ...[
                  const SizedBox(height: 14),
                  CourseProgressBar(value: overview.progress),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "5 دروس • 33%", the lesson count and a check when completed, or just
/// "لا توجد دروس" for a course without lessons.
class _Metadata extends StatelessWidget {
  const _Metadata({required this.overview});

  final CourseOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final small = theme.textTheme.bodySmall;
    final lessonCount =
        Text(StringsManager.lessons.trPlural(context, overview.lessonCount),
            style: small);

    if (!overview.hasLessons) return lessonCount;

    return Row(
      children: [
        lessonCount,
        Text('  •  ', style: small),
        if (overview.isCompleted) ...[
          Icon(Icons.check_circle_rounded, size: 16, color: scheme.secondary),
          const SizedBox(width: 4),
          Text(
            StringsManager.completed.tr(context),
            style: small?.copyWith(
                color: scheme.secondary, fontWeight: FontWeight.w600),
          ),
        ] else
          Text(
            '${overview.percent}%',
            style: small?.copyWith(
              fontWeight: FontWeight.w600,
              color: overview.percent == 0
                  ? scheme.onSurfaceVariant
                  : scheme.onSurface,
            ),
          ),
      ],
    );
  }
}

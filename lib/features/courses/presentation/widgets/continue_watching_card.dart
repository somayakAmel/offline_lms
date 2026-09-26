import 'package:flutter/material.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/functions/duration_format.dart';
import '../../../../src/core/theme/app_theme.dart';
import '../providers/home_state.dart';
import 'course_progress_bar.dart';
import 'course_thumbnail.dart';

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({
    super.key,
    required this.item,
    required this.onResume,
  });

  final ContinueWatching item;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onCard = scheme.onPrimaryContainer;

    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onResume,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CourseThumbnail(
                        asset: item.course.thumbnail,
                        width: 84,
                        height: 84,
                        radius: 16,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.play_arrow_rounded,
                              size: 22, color: AppColors.ink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: onCard.withValues(alpha: 0.75)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.lesson.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: onCard),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CourseProgressBar(
                value: item.progress,
                trackColor: onCard.withValues(alpha: 0.14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      StringsManager.watchedOf
                          .tr(context)
                          .replaceAll('{position}',
                              formatDuration(item.positionSeconds))
                          .replaceAll('{duration}',
                              formatDuration(item.lesson.durationSec)),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: onCard.withValues(alpha: 0.8)),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onResume,
                    style: FilledButton.styleFrom(
                      backgroundColor: onCard,
                      foregroundColor: scheme.primaryContainer,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(StringsManager.resumeLesson.tr(context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

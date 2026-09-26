import 'package:flutter/material.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/functions/duration_format.dart';

/// Sections, lessons and total duration, all derived from the course data.
class CourseStatsRow extends StatelessWidget {
  const CourseStatsRow({
    super.key,
    required this.sectionCount,
    required this.lessonCount,
    required this.totalDurationSec,
  });

  final int sectionCount;
  final int lessonCount;
  final int totalDurationSec;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 6,
      endIndent: 6,
      color: scheme.outlineVariant,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Stat(
              icon: Icons.view_agenda_outlined,
              value: '$sectionCount',
              label: StringsManager.sections.tr(context),
            ),
            divider,
            _Stat(
              icon: Icons.play_circle_outline_rounded,
              value: '$lessonCount',
              label: StringsManager.lessonsLabel.tr(context),
            ),
            divider,
            _Stat(
              icon: Icons.schedule_rounded,
              value: formatDuration(totalDurationSec),
              label: StringsManager.duration.tr(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.secondary),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

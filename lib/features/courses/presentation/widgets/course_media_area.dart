import 'package:flutter/material.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import 'course_thumbnail.dart';

/// Top of the course details screen: the course image, or the selected
/// lesson's player. The video player will replace [_PlayerPlaceholder].
class CourseMediaArea extends StatelessWidget {
  const CourseMediaArea({super.key, required this.course, this.lesson});

  final Course course;

  /// The selected (unlocked) lesson, if any.
  final Lesson? lesson;

  /// At most this share of the screen height, so the lesson list stays
  /// visible on wide or landscape screens.
  static const double maxHeightFraction = 0.4;

  @override
  Widget build(BuildContext context) {
    final selected = lesson;
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFraction;
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: double.infinity,
        height: (constraints.maxWidth * 9 / 16).clamp(0.0, maxHeight),
        child: _switcher(selected),
      ),
    );
  }

  Widget _switcher(Lesson? selected) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: selected == null
          ? LayoutBuilder(
              key: const ValueKey('thumbnail'),
              builder: (context, constraints) => CourseThumbnail(
                asset: course.thumbnail,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                radius: 0,
              ),
            )
          : _PlayerPlaceholder(key: ValueKey(selected.id), lesson: selected),
    );
  }
}

class _PlayerPlaceholder extends StatelessWidget {
  const _PlayerPlaceholder({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.play_arrow_rounded,
                      size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                lesson.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                StringsManager.lessonPlayerUnavailable.tr(context),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

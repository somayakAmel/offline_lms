import 'package:flutter/material.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import 'course_thumbnail.dart';
import 'lesson_player_view.dart';

/// Top of the course details screen: the course image, or the selected
/// lesson's video player.
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
        child: AnimatedSwitcher(
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
              // One fixed key: switching lessons swaps the video in place
              // instead of cross-fading two players (and two videos).
              : LessonPlayerView(
                  key: const ValueKey('player'),
                  lessonId: selected.id,
                ),
        ),
      ),
    );
  }
}

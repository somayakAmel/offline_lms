import 'package:flutter/material.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import 'course_thumbnail.dart';
import 'lesson_player_view.dart';

/// Top of the course details screen: the course image, or the selected
/// lesson's video player. It reaches the top edge of the screen, behind the
/// status bar ([topInset]) and the floating back button.
class CourseMediaArea extends StatelessWidget {
  const CourseMediaArea({
    super.key,
    required this.course,
    this.lesson,
    this.topInset = 0,
  });

  final Course course;

  /// The selected (unlocked) lesson, if any.
  final Lesson? lesson;

  /// Height of the status bar drawn over this area.
  final double topInset;

  /// At most this share of the screen height, so the lesson list stays
  /// visible on wide or landscape screens.
  static const double maxHeightFraction = 0.4;

  @override
  Widget build(BuildContext context) {
    final selected = lesson;
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFraction;
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaHeight = (constraints.maxWidth * 9 / 16).clamp(
          0.0,
          maxHeight,
        );
        return SizedBox(
          width: double.infinity,
          height: topInset + mediaHeight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: selected == null
                ? _CoverImage(
                    key: const ValueKey('thumbnail'),
                    asset: course.thumbnail,
                    scrimHeight: topInset + 64,
                  )
                // The video keeps clear of the status bar; the strip above it
                // is the player's black, so the section still reads as one.
                // One fixed key: switching lessons swaps the video in place
                // instead of cross-fading two players (and two videos).
                : ColoredBox(
                    key: const ValueKey('player'),
                    color: Colors.black,
                    child: Padding(
                      padding: EdgeInsets.only(top: topInset),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: LessonPlayerView(lessonId: selected.id),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

/// The course image edge to edge, darkened slightly at the top so the
/// status bar icons and the back button stay readable on light images.
class _CoverImage extends StatelessWidget {
  const _CoverImage({
    super.key,
    required this.asset,
    required this.scrimHeight,
  });

  final String asset;
  final double scrimHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          CourseThumbnail(
            asset: asset,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            radius: 0,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: scrimHeight,
              width: double.infinity,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x59000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

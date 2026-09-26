import 'package:flutter/material.dart';

/// Thin rounded progress bar that fills from the reading start (right in RTL).
/// At 0 it shows a small start dot on the track, so it reads as "not started"
/// rather than empty.
class CourseProgressBar extends StatelessWidget {
  const CourseProgressBar({
    super.key,
    required this.value,
    this.color,
    this.trackColor,
  });

  /// From 0 to 1.
  final double value;
  final Color? color;
  final Color? trackColor;

  static const double _height = 6;
  static const double _handleSize = 10;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = color ?? scheme.secondary;
    final progress = value.clamp(0.0, 1.0);

    return SizedBox(
      height: _handleSize,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_height / 2),
            child: SizedBox(
              width: double.infinity,
              height: _height,
              child: ColoredBox(
                color: trackColor ?? scheme.secondaryContainer,
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: progress,
                  child: ColoredBox(color: fill),
                ),
              ),
            ),
          ),
          if (progress == 0)
            Container(
              width: _handleSize,
              height: _handleSize,
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

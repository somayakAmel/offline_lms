class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    required this.watchedPositionSeconds,
    required this.completed,
    required this.updatedAt,
  });

  final String lessonId;

  /// Last known playback position.
  final int watchedPositionSeconds;
  final bool completed;
  final DateTime updatedAt;
}

/// Where the student stands with a lesson.
enum LessonStatus {
  /// The previous lesson isn't completed yet.
  locked,

  /// Unlocked and not started.
  available,

  /// Started but not completed.
  inProgress,

  completed,
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.durationSec,
    required this.video,
  });

  final String id;
  final String title;
  final int durationSec;

  /// Bundled asset path of the lesson video.
  final String video;
}

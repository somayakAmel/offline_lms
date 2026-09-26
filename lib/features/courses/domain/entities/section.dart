import 'lesson.dart';

class Section {
  const Section({
    required this.id,
    required this.title,
    required this.lessons,
  });

  final String id;
  final String title;
  final List<Lesson> lessons;

  /// Sum of this section's lesson durations, in seconds.
  int get totalDurationSec =>
      lessons.fold(0, (total, lesson) => total + lesson.durationSec);
}

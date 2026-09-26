import 'lesson.dart';
import 'section.dart';

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.sections,
  });

  final String id;
  final String title;
  final String instructor;

  /// Bundled asset path of the course thumbnail.
  final String thumbnail;
  final List<Section> sections;

  /// All lessons in section order.
  List<Lesson> get lessons => [
        for (final section in sections) ...section.lessons,
      ];

  /// Sum of all lesson durations, in seconds.
  int get totalDurationSec =>
      sections.fold(0, (total, section) => total + section.totalDurationSec);
}

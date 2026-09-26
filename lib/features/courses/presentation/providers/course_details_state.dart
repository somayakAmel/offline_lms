import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_status.dart';
import '../../domain/entities/section.dart';

/// Everything the course details screen shows, already calculated.
class CourseDetailsState {
  const CourseDetailsState({
    required this.course,
    required this.sections,
    required this.progress,
  });

  final Course course;
  final List<SectionItem> sections;

  /// Completed-lessons fraction, from 0 to 1.
  final double progress;

  int get sectionCount => course.sections.length;
  int get lessonCount => course.lessons.length;
  int get totalDurationSec => course.totalDurationSec;
  bool get hasLessons => lessonCount > 0;
  int get percent => (progress * 100).round();

  LessonItem? lessonById(String lessonId) {
    for (final section in sections) {
      for (final item in section.lessons) {
        if (item.lesson.id == lessonId) return item;
      }
    }
    return null;
  }
}

class SectionItem {
  const SectionItem({required this.section, required this.lessons});

  final Section section;
  final List<LessonItem> lessons;
}

class LessonItem {
  const LessonItem({
    required this.lesson,
    required this.status,
    required this.progress,
  });

  final Lesson lesson;
  final LessonStatus status;

  /// Watched fraction, from 0 to 1.
  final double progress;

  bool get isLocked => status == LessonStatus.locked;
}

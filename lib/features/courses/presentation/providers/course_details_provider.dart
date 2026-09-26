import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/courses_providers.dart';
import '../../domain/entities/lesson.dart';
import 'course_details_state.dart';
import 'home_notifier.dart';

/// Details of one course, or `null` if it is not in the catalog.
/// Reuses the catalog already loaded for Home.
final courseDetailsProvider =
    FutureProvider.autoDispose.family<CourseDetailsState?, String>(
  (ref, courseId) async {
    final home = await ref.watch(homeProvider.future);
    final course = home.courses
        .map((overview) => overview.course)
        .where((course) => course.id == courseId)
        .firstOrNull;
    if (course == null) return null;

    final progressService = ref.watch(progressServiceProvider);
    final allProgress =
        await ref.watch(progressRepositoryProvider).getAllLessonProgress();
    final progressByLessonId = {
      for (final progress in allProgress) progress.lessonId: progress,
    };

    LessonItem item(Lesson lesson) {
      final progress = progressByLessonId[lesson.id];
      return LessonItem(
        lesson: lesson,
        status: progressService.lessonStatus(course, lesson, progressByLessonId),
        progress: progress == null
            ? 0
            : progressService.lessonProgress(
                lesson, progress.watchedPositionSeconds),
      );
    }

    return CourseDetailsState(
      course: course,
      progress: progressService.courseProgress(course, progressByLessonId),
      sections: [
        for (final section in course.sections)
          SectionItem(
            section: section,
            lessons: [for (final lesson in section.lessons) item(lesson)],
          ),
      ],
    );
  },
  retry: (_, _) => null,
);

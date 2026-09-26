import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/services/progress_service.dart';
import '../../di/courses_providers.dart';
import 'home_state.dart';

/// No automatic retry: failures show an error state with a Retry button.
final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
  retry: (_, _) => null,
);

class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final progressRepository = ref.watch(progressRepositoryProvider);
    final progressService = ref.watch(progressServiceProvider);

    final (courses, allProgress, lastOpenedLessonId) = await (
      ref.watch(coursesRepositoryProvider).getCourses(),
      progressRepository.getAllLessonProgress(),
      progressRepository.getLastOpenedLessonId(),
    ).wait;

    final progressByLessonId = {
      for (final progress in allProgress) progress.lessonId: progress,
    };

    return HomeState(
      courses: [
        for (final course in courses)
          CourseOverview(
            course: course,
            progress: progressService.courseProgress(course, progressByLessonId),
          ),
      ],
      continueWatching: _continueWatching(
        courses,
        progressByLessonId,
        lastOpenedLessonId,
        progressService,
      ),
    );
  }

  /// Reloads courses and progress, keeping the current content on screen.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  ContinueWatching? _continueWatching(
    List<Course> courses,
    Map<String, LessonProgress> progressByLessonId,
    String? lastOpenedLessonId,
    ProgressService progressService,
  ) {
    if (lastOpenedLessonId == null) return null;
    for (final course in courses) {
      for (final lesson in course.lessons) {
        if (lesson.id != lastOpenedLessonId) continue;
        final progress = progressByLessonId[lesson.id];
        if (!progressService.isLessonInProgress(lesson, progress)) return null;
        return ContinueWatching(
          course: course,
          lesson: lesson,
          positionSeconds: progress!.watchedPositionSeconds,
          progress: progressService.lessonProgress(
            lesson,
            progress.watchedPositionSeconds,
          ),
        );
      }
    }
    // The saved lesson is no longer in the bundled catalog.
    return null;
  }
}

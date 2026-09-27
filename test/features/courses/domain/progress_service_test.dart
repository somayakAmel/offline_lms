import 'package:flutter_test/flutter_test.dart';
import 'package:offline_lms/features/courses/domain/entities/course.dart';
import 'package:offline_lms/features/courses/domain/entities/lesson.dart';
import 'package:offline_lms/features/courses/domain/entities/lesson_progress.dart';
import 'package:offline_lms/features/courses/domain/entities/section.dart';
import 'package:offline_lms/features/courses/domain/services/progress_service.dart';

/// Unit tests for the three progress rules required by the task:
/// 90% completion, sequential unlock, and course progress percentage.
void main() {
  const service = ProgressService();

  // A small course: two sections, three 60-second lessons in this order:
  // lesson-1, lesson-2 (section 1), lesson-3 (section 2).
  const course = Course(
    id: 'course',
    title: 'Course',
    instructor: 'Instructor',
    thumbnail: 'thumbnail.png',
    sections: [
      Section(
        id: 'section-1',
        title: 'Section 1',
        lessons: [
          Lesson(
            id: 'lesson-1',
            title: 'Lesson 1',
            durationSec: 60,
            video: 'v.mp4',
          ),
          Lesson(
            id: 'lesson-2',
            title: 'Lesson 2',
            durationSec: 60,
            video: 'v.mp4',
          ),
        ],
      ),
      Section(
        id: 'section-2',
        title: 'Section 2',
        lessons: [
          Lesson(
            id: 'lesson-3',
            title: 'Lesson 3',
            durationSec: 60,
            video: 'v.mp4',
          ),
        ],
      ),
    ],
  );

  /// Saved progress for [lessonId], as the app stores it.
  LessonProgress progress(
    String lessonId, {
    int positionSeconds = 60,
    bool completed = true,
  }) => LessonProgress(
    lessonId: lessonId,
    watchedPositionSeconds: positionSeconds,
    completed: completed,
    updatedAt: DateTime(2026),
  );

  group('90% completion rule', () {
    test('a lesson is not completed below 90%', () {
      // 53 of 60 seconds is about 88%.
      expect(
        service.isLessonCompleted(positionSeconds: 53, durationSeconds: 60),
        isFalse,
      );
    });

    test('a lesson is completed at exactly 90% and above', () {
      // 54 of 60 seconds is exactly 90%.
      expect(
        service.isLessonCompleted(positionSeconds: 54, durationSeconds: 60),
        isTrue,
      );
      expect(
        service.isLessonCompleted(positionSeconds: 60, durationSeconds: 60),
        isTrue,
      );
    });

    test('a lesson without a duration is never completed', () {
      expect(
        service.isLessonCompleted(positionSeconds: 10, durationSeconds: 0),
        isFalse,
      );
    });
  });

  group('Lesson unlock rule', () {
    test('the first lesson is unlocked with no progress', () {
      expect(service.isLessonUnlocked(course, 'lesson-1', {}), isTrue);
    });

    test(
      'the next lesson stays locked while the previous is not completed',
      () {
        // Nothing watched yet.
        expect(service.isLessonUnlocked(course, 'lesson-2', {}), isFalse);

        // Lesson 1 half watched: started, but not completed.
        final halfWatched = {
          'lesson-1': progress(
            'lesson-1',
            positionSeconds: 30,
            completed: false,
          ),
        };
        expect(
          service.isLessonUnlocked(course, 'lesson-2', halfWatched),
          isFalse,
        );
      },
    );

    test('the next lesson unlocks once the previous is completed', () {
      final lesson1Done = {'lesson-1': progress('lesson-1')};
      expect(service.isLessonUnlocked(course, 'lesson-2', lesson1Done), isTrue);
    });

    test('completing lesson 1 does not unlock lesson 3', () {
      final lesson1Done = {'lesson-1': progress('lesson-1')};
      expect(
        service.isLessonUnlocked(course, 'lesson-3', lesson1Done),
        isFalse,
      );
    });

    test('the order continues across sections', () {
      // Lesson 3 is the first lesson of section 2: it depends on lesson 2,
      // the last lesson of section 1.
      final lesson1Done = {'lesson-1': progress('lesson-1')};
      final lessons1And2Done = {
        'lesson-1': progress('lesson-1'),
        'lesson-2': progress('lesson-2'),
      };
      expect(
        service.isLessonUnlocked(course, 'lesson-3', lesson1Done),
        isFalse,
      );
      expect(
        service.isLessonUnlocked(course, 'lesson-3', lessons1And2Done),
        isTrue,
      );
    });
  });

  group('Progress percentage calculation', () {
    // courseProgress returns a fraction from 0 to 1; the app shows it
    // multiplied by 100 (0.5 is shown as 50%).

    test('a partially completed course counts only completed lessons', () {
      final oneDoneOneHalfWatched = {
        'lesson-1': progress('lesson-1'),
        'lesson-2': progress('lesson-2', positionSeconds: 30, completed: false),
      };
      // 1 of 3 lessons completed = 33%; the half-watched lesson adds nothing.
      expect(
        service.courseProgress(course, oneDoneOneHalfWatched),
        closeTo(1 / 3, 1e-9),
      );
    });

    test('all lessons completed is 100%', () {
      final allDone = {
        'lesson-1': progress('lesson-1'),
        'lesson-2': progress('lesson-2'),
        'lesson-3': progress('lesson-3'),
      };
      expect(service.courseProgress(course, allDone), 1.0);
    });

    test('a course with no lessons is 0%', () {
      const emptyCourse = Course(
        id: 'empty',
        title: 'Empty',
        instructor: 'Instructor',
        thumbnail: 'thumbnail.png',
        sections: [],
      );
      expect(service.courseProgress(emptyCourse, {}), 0.0);
    });
  });
}

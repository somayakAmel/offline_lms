import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_lms/src/features/courses/data/datasources/courses_local_data_source.dart';
import 'package:offline_lms/src/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:offline_lms/src/features/courses/domain/entities/course.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Course> courses;

  setUpAll(() async {
    courses =
        await CoursesRepositoryImpl(CoursesLocalDataSourceImpl()).getCourses();
  });

  test('bundled catalog has 2 courses with 2 sections of 2–3 lessons each', () {
    expect(courses, hasLength(2));
    for (final course in courses) {
      expect(course.sections, hasLength(2), reason: course.id);
      for (final section in course.sections) {
        expect(section.lessons.length, inInclusiveRange(2, 3),
            reason: section.id);
      }
    }
  });

  test('ids are unique across the whole catalog', () {
    final ids = [
      for (final course in courses) ...[
        course.id,
        for (final section in course.sections) ...[
          section.id,
          for (final lesson in section.lessons) lesson.id,
        ],
      ],
    ];
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('every lesson has a positive duration', () {
    for (final course in courses) {
      for (final section in course.sections) {
        for (final lesson in section.lessons) {
          expect(lesson.durationSec, greaterThan(0), reason: lesson.id);
        }
      }
    }
  });

  test('every thumbnail and video path points to a bundled asset', () async {
    final paths = {
      for (final course in courses) ...[
        course.thumbnail,
        for (final section in course.sections)
          for (final lesson in section.lessons) lesson.video,
      ],
    };
    for (final path in paths) {
      await expectLater(rootBundle.load(path), completes, reason: path);
    }
  });
}

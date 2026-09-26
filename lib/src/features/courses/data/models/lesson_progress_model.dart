import '../../domain/entities/lesson_progress.dart';

class LessonProgressModel {
  const LessonProgressModel({
    required this.lessonId,
    required this.watchedPositionSeconds,
    required this.completed,
    required this.updatedAt,
  });

  factory LessonProgressModel.fromMap(Map<String, Object?> map) =>
      LessonProgressModel(
        lessonId: map['lesson_id'] as String,
        watchedPositionSeconds: map['watched_position_seconds'] as int,
        completed: map['completed'] == 1,
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      );

  factory LessonProgressModel.fromEntity(LessonProgress progress) =>
      LessonProgressModel(
        lessonId: progress.lessonId,
        watchedPositionSeconds: progress.watchedPositionSeconds,
        completed: progress.completed,
        updatedAt: progress.updatedAt,
      );

  final String lessonId;
  final int watchedPositionSeconds;
  final bool completed;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
        'lesson_id': lessonId,
        'watched_position_seconds': watchedPositionSeconds,
        'completed': completed ? 1 : 0,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  LessonProgress toEntity() => LessonProgress(
        lessonId: lessonId,
        watchedPositionSeconds: watchedPositionSeconds,
        completed: completed,
        updatedAt: updatedAt,
      );
}

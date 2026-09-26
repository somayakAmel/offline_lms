import '../../domain/entities/lesson.dart';

class LessonModel {
  const LessonModel({
    required this.id,
    required this.title,
    required this.durationSec,
    required this.video,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
        id: json['id'] as String,
        title: json['title'] as String,
        durationSec: json['durationSec'] as int,
        video: json['video'] as String,
      );

  final String id;
  final String title;
  final int durationSec;
  final String video;

  Lesson toEntity() => Lesson(
        id: id,
        title: title,
        durationSec: durationSec,
        video: video,
      );
}

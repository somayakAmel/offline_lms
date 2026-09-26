import '../../domain/entities/section.dart';
import 'lesson_model.dart';

class SectionModel {
  const SectionModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) => SectionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        lessons: (json['lessons'] as List<dynamic>)
            .map((lesson) => LessonModel.fromJson(lesson as Map<String, dynamic>))
            .toList(growable: false),
      );

  final String id;
  final String title;
  final List<LessonModel> lessons;

  Section toEntity() => Section(
        id: id,
        title: title,
        lessons: lessons
            .map((lesson) => lesson.toEntity())
            .toList(growable: false),
      );
}

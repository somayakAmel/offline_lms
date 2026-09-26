import '../../domain/entities/course.dart';
import 'section_model.dart';

class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.sections,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'] as String,
        title: json['title'] as String,
        instructor: json['instructor'] as String,
        thumbnail: json['thumbnail'] as String,
        sections: (json['sections'] as List<dynamic>)
            .map((section) =>
                SectionModel.fromJson(section as Map<String, dynamic>))
            .toList(growable: false),
      );

  final String id;
  final String title;
  final String instructor;
  final String thumbnail;
  final List<SectionModel> sections;

  Course toEntity() => Course(
        id: id,
        title: title,
        instructor: instructor,
        thumbnail: thumbnail,
        sections: sections
            .map((section) => section.toEntity())
            .toList(growable: false),
      );
}

import '../../domain/entities/lesson_note.dart';

class LessonNoteModel {
  const LessonNoteModel({
    required this.lessonId,
    required this.content,
    required this.updatedAt,
  });

  factory LessonNoteModel.fromMap(Map<String, Object?> map) => LessonNoteModel(
        lessonId: map['lesson_id'] as String,
        content: map['content'] as String,
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      );

  factory LessonNoteModel.fromEntity(LessonNote note) => LessonNoteModel(
        lessonId: note.lessonId,
        content: note.content,
        updatedAt: note.updatedAt,
      );

  final String lessonId;
  final String content;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
        'lesson_id': lessonId,
        'content': content,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  LessonNote toEntity() => LessonNote(
        lessonId: lessonId,
        content: content,
        updatedAt: updatedAt,
      );
}

class LessonNote {
  const LessonNote({
    required this.lessonId,
    required this.content,
    required this.updatedAt,
  });

  final String lessonId;
  final String content;
  final DateTime updatedAt;
}

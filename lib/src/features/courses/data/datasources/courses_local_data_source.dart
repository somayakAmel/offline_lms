import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course_model.dart';

abstract interface class CoursesLocalDataSource {
  Future<List<CourseModel>> getCourses();
}

/// Reads the course catalog bundled at [coursesAssetPath].
class CoursesLocalDataSourceImpl implements CoursesLocalDataSource {
  CoursesLocalDataSourceImpl({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  static const String coursesAssetPath = 'assets/data/courses.json';

  final AssetBundle _bundle;

  @override
  Future<List<CourseModel>> getCourses() async {
    final jsonString = await _bundle.loadString(coursesAssetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return (json['courses'] as List<dynamic>)
        .map((course) => CourseModel.fromJson(course as Map<String, dynamic>))
        .toList(growable: false);
  }
}

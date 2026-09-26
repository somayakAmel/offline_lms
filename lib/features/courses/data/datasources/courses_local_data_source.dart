import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course_model.dart';

abstract interface class CoursesLocalDataSource {
  Future<List<CourseModel>> getCourses();
}

/// Reads the course catalog bundled at [coursesAssetPath].
class CoursesLocalDataSourceImpl implements CoursesLocalDataSource {
  CoursesLocalDataSourceImpl({
    AssetBundle? bundle,
    this.simulatedLatency = const Duration(milliseconds: 1500),
  }) : _bundle = bundle ?? rootBundle;

  static const String coursesAssetPath = 'assets/data/courses.json';

  final AssetBundle _bundle;

  /// The catalog is bundled, so it loads almost instantly. This delay
  /// simulates fetching it, so the app's loading state is visible.
  final Duration simulatedLatency;

  @override

  Future<List<CourseModel>> getCourses() async {
    await Future<void>.delayed(simulatedLatency);
    final jsonString = await _bundle.loadString(coursesAssetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return (json['courses'] as List<dynamic>)
        .map((course) => CourseModel.fromJson(course as Map<String, dynamic>))
        .toList(growable: false);
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  AppRoutes._();

  static const String courses = '/courses';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.courses,
  routes: [
    // go_router needs at least one route; replace the builder with the
    // courses screen once it exists.
    GoRoute(
      path: AppRoutes.courses,
      builder: (context, state) => const Scaffold(),
    ),
  ],
);

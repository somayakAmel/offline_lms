import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/courses/presentation/pages/course_details_page.dart';
import '../../features/courses/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../core/router/app_routes.dart';
import 'main_shell.dart';

/// App-level router: the only place that knows every screen.
final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.courses,
              builder: (context, state) => const HomePage(),
              routes: [
                // Full screen, above the floating navigation.
                GoRoute(
                  path: ':courseId',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => CourseDetailsPage(
                    courseId: state.pathParameters['courseId']!,
                    initialLessonId:
                        state.uri.queryParameters[AppRoutes.lessonQuery],
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

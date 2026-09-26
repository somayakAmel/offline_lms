import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/router/app_routes.dart';
import '../../../../src/core/theme/app_layout.dart';
import '../providers/home_notifier.dart';
import '../providers/home_state.dart';
import '../widgets/continue_watching_card.dart';
import '../widgets/course_card.dart';
import '../widgets/education_pattern.dart';
import '../widgets/status_views.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final padding =
        AppLayout.horizontalPadding(MediaQuery.sizeOf(context).width);

    final List<Widget> body;
    if (home.hasValue) {
      body = _content(context, home.requireValue);
    } else if (home.isLoading) {
      body = [
        _SectionTitle(StringsManager.courses.tr(context)),
        const CoursesLoadingView(),
      ];
    } else {
      body = [
        CoursesErrorView(
          onRetry: () => ref.read(homeProvider.notifier).refresh(),
        ),
      ];
    }

    return Stack(
      children: [
        const Positioned.fill(child: EducationPattern()),
        SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => ref.read(homeProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding.copyWith(
                top: 28,
                bottom: AppLayout.navBarClearance +
                    MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                const _Header(),
                const SizedBox(height: 28),
                ...body,
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _content(BuildContext context, HomeState state) {
    final continueWatching = state.continueWatching;
    return [
      if (continueWatching != null) ...[
        _SectionTitle(StringsManager.continueWatching.tr(context)),
        ContinueWatchingCard(
          item: continueWatching,
          onResume: () => context.push(AppRoutes.courseDetails(
            continueWatching.course.id,
            lessonId: continueWatching.lesson.id,
          )),
        ),
        const SizedBox(height: 32),
      ],
      _SectionTitle(StringsManager.courses.tr(context)),
      if (state.courses.isEmpty)
        const CoursesEmptyView()
      else
        for (final (index, overview) in state.courses.indexed) ...[
          if (index > 0) const SizedBox(height: 14),
          CourseCard(
            overview: overview,
            onTap: () =>
                context.push(AppRoutes.courseDetails(overview.course.id)),
          ),
        ],
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(StringsManager.welcomeTitle.tr(context),
              style: theme.textTheme.headlineSmall),
        ),
        const SizedBox(height: 6),
        Text(
          StringsManager.welcomeSubtitle.tr(context),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

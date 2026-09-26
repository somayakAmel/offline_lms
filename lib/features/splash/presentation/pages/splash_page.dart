import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/router/app_routes.dart';
import '../../../../src/core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// How long the splash stays before Home opens. Home loads its own data
  /// and shows a loading state meanwhile.
  static const Duration duration = Duration(milliseconds: 1200);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(SplashPage.duration, () {
      if (mounted) context.go(AppRoutes.courses);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? scheme.surface : AppColors.splashBackground;
    final foreground = scheme.onSurface;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: background,
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: isDark ? scheme.primary : scheme.onPrimary,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 46,
                      color: isDark ? scheme.onPrimary : scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    StringsManager.appName,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: foreground),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    StringsManager.splashTagline.tr(context),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: foreground.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

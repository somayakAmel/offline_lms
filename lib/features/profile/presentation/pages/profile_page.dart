import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../src/core/localization/l10n/locale_provider.dart';
import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/theme/app_layout.dart';
import '../../../../src/core/theme/theme_mode_provider.dart';

/// Demo user shown on the profile. The app has no accounts.
abstract final class _DemoUser {
  static const String name = 'Somaya Kamel';
  static const String initials = 'SK';
  static const String email = 'somayaa.kamell@gmail.com';
  static const String phone = '01140239195';
}

/// User details and the app's theme and language settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding =
        AppLayout.horizontalPadding(MediaQuery.sizeOf(context).width);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: padding.copyWith(
          top: 28,
          bottom:
              AppLayout.navBarClearance + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const _UserHeader(),
          const SizedBox(height: 32),
          _SectionTitle(StringsManager.personalInformation.tr(context)),
          _Card(children: [
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: StringsManager.name.tr(context),
              value: _DemoUser.name,
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              label: StringsManager.email.tr(context),
              value: _DemoUser.email,
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: StringsManager.phone.tr(context),
              value: _DemoUser.phone,
            ),
          ]),
          const SizedBox(height: 32),
          _SectionTitle(StringsManager.appearance.tr(context)),
          const _Card(children: [_ThemeSetting(), _LanguageSetting()]),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: scheme.primaryContainer,
          child: Text(
            _DemoUser.initials,
            style: theme.textTheme.titleLarge
                ?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 14),
        Text(_DemoUser.name,
            textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          _DemoUser.email,
          textAlign: TextAlign.center,
          // Email reads left to right in Arabic too.
          textDirection: TextDirection.ltr,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
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

/// A rounded card with a divider between its rows.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0)
              Divider(height: 1, indent: 16, endIndent: 16,
                  color: scheme.outlineVariant),
            child,
          ],
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 22, color: scheme.onSecondaryContainer),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBadge(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    // Name, email and phone are Latin: keep them left to
                    // right, placed at the start of the row in Arabic too.
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An icon and label above a full-width choice.
class _SettingGroup extends StatelessWidget {
  const _SettingGroup({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IconBadge(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ThemeSetting extends ConsumerWidget {
  const _ThemeSetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingGroup(
      icon: Icons.palette_outlined,
      label: StringsManager.theme.tr(context),
      child: SegmentedButton<ThemeMode>(
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: ThemeMode.system,
            icon: const Icon(Icons.brightness_auto_outlined),
            label: Text(StringsManager.themeSystem.tr(context)),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: const Icon(Icons.light_mode_outlined),
            label: Text(StringsManager.themeLight.tr(context)),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: const Icon(Icons.dark_mode_outlined),
            label: Text(StringsManager.themeDark.tr(context)),
          ),
        ],
        selected: {ref.watch(themeModeProvider)},
        onSelectionChanged: (selection) => ref
            .read(themeModeProvider.notifier)
            .changeThemeMode(selection.single),
      ),
    );
  }
}

class _LanguageSetting extends ConsumerWidget {
  const _LanguageSetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingGroup(
      icon: Icons.translate_rounded,
      label: StringsManager.language.tr(context),
      child: SegmentedButton<Locale>(
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: const Locale('ar'),
            label: Text(StringsManager.languageArabic.tr(context)),
          ),
          ButtonSegment(
            value: const Locale('en'),
            label: Text(StringsManager.languageEnglish.tr(context)),
          ),
        ],
        selected: {ref.watch(localeProvider)},
        onSelectionChanged: (selection) =>
            ref.read(localeProvider.notifier).changeLocale(selection.single),
      ),
    );
  }
}

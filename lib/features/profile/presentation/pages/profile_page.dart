import 'package:flutter/material.dart';

import '../../../../src/core/localization/l10n/localization_extension.dart';
import '../../../../src/core/localization/l10n/strings_manager.dart';
import '../../../../src/core/theme/app_layout.dart';

/// Placeholder until user details, language and theme settings are added.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: AppLayout.horizontalPadding(MediaQuery.sizeOf(context).width)
              .copyWith(bottom: AppLayout.navBarClearance),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.person_rounded,
                    size: 44, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(StringsManager.profile.tr(context),
                    style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: 6),
              Text(
                StringsManager.profilePlaceholder.tr(context),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

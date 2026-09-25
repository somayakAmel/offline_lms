import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension LocaleExtension on String {
  String tr(BuildContext context) =>
      AppLocalizations.of(context)?.translate(this) ??
      (kReleaseMode ? this : 'Error : not found $this');
}

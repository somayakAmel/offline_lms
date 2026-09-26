import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:offline_lms/src/app/app.dart';
import 'package:offline_lms/src/core/di/service_locator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await initDependencies();
  });

  testWidgets('App starts in Arabic', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    expect(Localizations.localeOf(context), const Locale('ar'));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}

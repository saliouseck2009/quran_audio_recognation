// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ayat_finder/core/di/service_locator.dart';
import 'package:ayat_finder/src/app.dart';

void main() {
  testWidgets('Ayat Finder renders app shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1400, 3000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await setupDependencies();
    await tester.pumpWidget(const AyatFinderApp());
    await tester.pump();

    expect(find.textContaining('Ayat Detector'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:native_glass_navbar_example/main.dart';

void main() {
  testWidgets('shows the example gallery', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Native Liquid Tab Bar Examples'), findsOneWidget);
    expect(find.text('Action Button'), findsOneWidget);
  });
}

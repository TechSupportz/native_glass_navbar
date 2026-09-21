import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import 'package:native_glass_navbar_example/badge_tabs.dart';

void main() {
  testWidgets('badge demo updates and clears per-tab values', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BadgeTabsApp()));

    List<String?> badges() => tester
        .widget<NativeGlassNavBar>(find.byType(NativeGlassNavBar))
        .tabs
        .map((tab) => tab.badgeValue)
        .toList();

    expect(badges(), [null, '3', '!']);

    await tester.tap(find.text('Add message'));
    await tester.pump();
    expect(badges(), [null, '4', '!']);

    await tester.tap(find.text('Mark all read'));
    await tester.pump();
    expect(badges(), [null, null, '!']);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(badges(), [null, null, null]);
  });
}

import 'package:flutter/material.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

class BadgeTabsApp extends StatefulWidget {
  const BadgeTabsApp({super.key});

  @override
  State<BadgeTabsApp> createState() => _BadgeTabsAppState();
}

class _BadgeTabsAppState extends State<BadgeTabsApp> {
  int _currentIndex = 0;
  int _unreadCount = 3;
  bool _hasAlert = true;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const NativeGlassNavBarItem(label: 'Home', symbol: 'house.fill'),
      NativeGlassNavBarItem(
        label: 'Inbox',
        symbol: 'tray.fill',
        badgeValue: _unreadCount == 0 ? null : '$_unreadCount',
      ),
      NativeGlassNavBarItem(
        label: 'Alerts',
        symbol: 'bell.fill',
        badgeValue: _hasAlert ? '!' : null,
      ),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('Tab Badges')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Unread messages: $_unreadCount'),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => setState(() => _unreadCount++),
                  child: const Text('Add message'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _unreadCount = 0),
                  child: const Text('Mark all read'),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Show alert badge'),
              value: _hasAlert,
              onChanged: (value) => setState(() => _hasAlert = value),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NativeGlassNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        tabs: tabs,
        fallback: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
            NavigationDestination(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'action_button_counter.dart';
import 'badge_tabs.dart';
import 'basic_two_tabs.dart';
import 'custom_color_tabs.dart';
import 'custom_icon_tabs.dart';
import 'demo_page.dart';
import 'fallback_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1.75),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1.5, color: Colors.grey.withValues(alpha: 0.25)),
        ),
        floatingLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 24,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1.75),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1.5, color: Colors.grey.withValues(alpha: 0.25)),
        ),
        floatingLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
      ),
      dialogTheme: const DialogThemeData(
        titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
      ),
    );

    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = [
      _ExampleItem(
        title: 'Full Demo',
        description: 'Interactive configuration of tabs and action button',
        icon: Icons.settings_applications_rounded,
        page: const DemoPage(),
      ),
      _ExampleItem(
        title: 'Basic 2 Tabs',
        description: 'Simple example with 2 tabs',
        icon: Icons.looks_two_rounded,
        page: const BasicTwoTabsApp(),
      ),
      _ExampleItem(
        title: 'Action Button',
        description: '3 tabs with a central action button',
        icon: Icons.add_circle_rounded,
        page: const ActionButtonCounterApp(),
      ),
      _ExampleItem(
        title: 'Tab Badges',
        description: 'Update and clear native badges on individual tabs',
        icon: Icons.mark_email_unread_rounded,
        page: const BadgeTabsApp(),
      ),
      _ExampleItem(
        title: 'Custom Color',
        description: 'Example with custom tint color',
        icon: Icons.color_lens_rounded,
        page: const CustomColorTabsApp(),
      ),
      _ExampleItem(
        title: 'Custom Icons',
        description: 'Use named image assets for tab and action button icons',
        icon: Icons.widgets_rounded,
        page: const CustomIconTabsApp(),
      ),
      _ExampleItem(
        title: 'Fallback Demo',
        description: 'Example with Material fallback',
        icon: Icons.alt_route_rounded,
        page: const FallbackDemo(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Native Liquid Tab Bar Examples')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: examples.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final example = examples[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(example.icon, size: 40, color: Theme.of(context).colorScheme.primary),
              title: Text(
                example.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(example.description, style: const TextStyle(fontSize: 14)),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => example.page));
              },
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

class _ExampleItem {
  final String title;
  final String description;
  final IconData icon;
  final Widget page;

  _ExampleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.page,
  });
}

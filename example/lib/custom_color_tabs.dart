import 'package:material_ui/material_ui.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

void main() {
  runApp(const MaterialApp(home: CustomColorTabsApp()));
}

class CustomColorTabsApp extends StatefulWidget {
  const CustomColorTabsApp({super.key});

  @override
  State<CustomColorTabsApp> createState() => _CustomColorTabsAppState();
}

class _CustomColorTabsAppState extends State<CustomColorTabsApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Theme.of(context).brightness,
      ),
      child: Scaffold(
        extendBody: true, // NOTE - Enable to allow elements to be drawn behind the tab bar
        appBar: AppBar(title: const Text('Custom Color Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selected Index: $_currentIndex',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This example uses a custom orange tint color instead of the theme colour',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        bottomNavigationBar: NativeGlassNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          tintColor: Colors.deepOrange,
          tabs: const [
            NativeGlassNavBarItem(label: 'Favorites', symbol: 'star.fill'),
            NativeGlassNavBarItem(label: 'Recents', symbol: 'clock.fill'),
            NativeGlassNavBarItem(label: 'Contacts', symbol: 'person.2.fill'),
            NativeGlassNavBarItem(
              label: 'Keypad',
              symbol: 'circle.grid.3x3.fill',
            ),
          ],
        ),
      ),
    );
  }
}

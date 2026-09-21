import 'package:material_ui/material_ui.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

void main() {
  runApp(const MaterialApp(home: CustomIconTabsApp()));
}

class CustomIconTabsApp extends StatefulWidget {
  const CustomIconTabsApp({super.key});

  @override
  State<CustomIconTabsApp> createState() => _CustomIconTabsAppState();
}

class _CustomIconTabsAppState extends State<CustomIconTabsApp> {
  int _currentIndex = 0;

  static const _tabs = [
    NativeGlassNavBarItem(label: 'Home', symbol: 'material_home'),
    NativeGlassNavBarItem(label: 'Search', symbol: 'material_search'),
    NativeGlassNavBarItem(label: 'Profile', symbol: 'material_person'),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final selectedTab = _tabs[_currentIndex];

    return Scaffold(
      extendBody: true, // NOTE - Enable to allow elements to be drawn behind the tab bar
      appBar: AppBar(title: const Text('Custom Icon Assets')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 8),
              Text(
                'Currently selected asset: ${selectedTab.symbol}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              const Text(
                'Using custom image assets for tab and action button icons.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'NOTE: Image assets need to be manually added to the project via Xcode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NativeGlassNavBar(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        actionButton: TabBarActionButton(
          symbol: 'material_add',
          onTap: () {
            debugPrint('Action button tapped');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action button tapped')),
            );
          },
        ),
      ),
    );
  }
}

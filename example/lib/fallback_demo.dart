import 'package:material_ui/material_ui.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

class FallbackDemo extends StatefulWidget {
  const FallbackDemo({super.key});

  @override
  State<FallbackDemo> createState() => _FallbackDemoState();
}

class _FallbackDemoState extends State<FallbackDemo> {
  int _currentIndex = 0;

  final List<NativeGlassNavBarItem> _tabs = [
    NativeGlassNavBarItem(label: 'Home', symbol: 'house.fill'),
    NativeGlassNavBarItem(label: 'Search', symbol: 'magnifyingglass'),
    NativeGlassNavBarItem(label: 'Profile', symbol: 'person.fill'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fallback Demo')),
      body: Center(
        child: Text(
          'Current Index: $_currentIndex',
          style: Theme.of(context).textTheme.headlineMedium,
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
        fallback: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

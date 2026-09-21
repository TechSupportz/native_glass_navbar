import 'package:material_ui/material_ui.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

void main() {
  runApp(const MaterialApp(home: ActionButtonCounterApp()));
}

class ActionButtonCounterApp extends StatefulWidget {
  const ActionButtonCounterApp({super.key});

  @override
  State<ActionButtonCounterApp> createState() => _ActionButtonCounterAppState();
}

class _ActionButtonCounterAppState extends State<ActionButtonCounterApp> {
  int _currentIndex = 0;
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Theme.of(context).brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Theme.of(context).brightness,
        ),
      ),
      child: Scaffold(
        extendBody: true, // NOTE - Enable to allow elements to be drawn behind the tab bar
        appBar: AppBar(title: const Text('Action Button Counter Example')),
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
              const SizedBox(height: 32),
              Text(
                'Counter: $_counter',
                style: const TextStyle(fontSize: 32, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the + button to increment',
                style: TextStyle(color: Colors.grey),
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
          tabs: const [
            NativeGlassNavBarItem(label: 'Home', symbol: 'house.fill'),
            NativeGlassNavBarItem(label: 'Search', symbol: 'magnifyingglass'),
            NativeGlassNavBarItem(label: 'Profile', symbol: 'person.fill'),
          ],
          actionButton: TabBarActionButton(
            symbol: 'plus',
            onTap: () {
              setState(() {
                _counter++;
              });
            },
          ),
        ),
      ),
    );
  }
}

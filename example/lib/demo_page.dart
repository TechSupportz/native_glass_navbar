import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  int _currentIndex = 0;
  int _refreshKey = 0;

  bool _isActionButtonEnabled = true;
  String _actionButtonSymbol = 'plus';
  late TextEditingController _actionButtonController;

  bool _isBackgroundItemsEnabled = false;

  final List<NativeGlassNavBarItem> _tabs = [
    NativeGlassNavBarItem(label: 'Home', symbol: 'heart.fill'),
    NativeGlassNavBarItem(label: 'Search', symbol: 'magnifyingglass'),
    NativeGlassNavBarItem(label: 'Settings', symbol: 'gear'),
  ];

  @override
  void initState() {
    super.initState();
    _actionButtonController = TextEditingController(text: _actionButtonSymbol);
  }

  @override
  void dispose() {
    _actionButtonController.dispose();
    super.dispose();
  }

  void _addTab() {
    if (_tabs.length >= (_isActionButtonEnabled ? 4 : 5)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum number of tabs reached')),
      );
      return;
    }
    setState(() {
      _tabs.add(const NativeGlassNavBarItem(label: 'New', symbol: 'star'));
      _refreshKey++;
    });
  }

  void _removeTab(int index) {
    setState(() {
      _tabs.removeAt(index);
      if (_currentIndex >= _tabs.length) {
        _currentIndex = _tabs.isNotEmpty ? _tabs.length - 1 : 0;
      }
      _refreshKey++;
    });
  }

  void _editTab(int index) async {
    final item = _tabs[index];
    final labelController = TextEditingController(text: item.label);
    final symbolController = TextEditingController(text: item.symbol);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tab'),
        contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            TextField(
              controller: symbolController,
              decoration: const InputDecoration(
                labelText: 'SF Symbol Name',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tabs[index] = NativeGlassNavBarItem(
                  label: labelController.text,
                  symbol: symbolController.text,
                );
                _refreshKey++;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true, // NOTE - Enable to allow elements to be drawn behind the tab bar
      appBar: AppBar(title: const Text('Native Liquid Tab Bar Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Selected Index: $_currentIndex',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tabs',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _addTab),
            ],
          ),
          ..._tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            return ListTile(
              title: Text(
                tab.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(tab.symbol),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8.0,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => _editTab(index),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () => _removeTab(index),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        colorScheme.errorContainer,
                      ),
                      foregroundColor: WidgetStateProperty.all(
                        colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () => _editTab(index),
            );
          }),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SwitchListTile(
              contentPadding: EdgeInsets.all(0),
              title: const Text(
                'Action Button',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              value: _isActionButtonEnabled,
              onChanged: (value) {
                if (value && _tabs.length > 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Remove a tab first (Max 4 with action button)',
                      ),
                    ),
                  );
                  return;
                }

                if (_actionButtonSymbol.isEmpty) {
                  setState(() {
                    _actionButtonController.text = 'plus';
                    _actionButtonSymbol = 'plus';
                  });
                }

                setState(() => _isActionButtonEnabled = value);
              },
            ),
          ),
          if (_isActionButtonEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _actionButtonController,
                decoration: InputDecoration(
                  labelText: 'Symbol',
                  fillColor: colorScheme.surfaceContainer,
                ),
                onChanged: (value) => setState(() {
                  _actionButtonSymbol = value;
                }),
              ),
            ),
          Padding(padding: const EdgeInsets.only(top: 16.0), child: Divider()),
          SwitchListTile(
            contentPadding: EdgeInsets.all(0),
            title: const Text(
              'Background Items',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            value: _isBackgroundItemsEnabled,
            onChanged: (value) {
              setState(() => _isBackgroundItemsEnabled = value);
            },
          ),
          const SizedBox(height: 16),
          if (_isBackgroundItemsEnabled)
            Column(
              children: List.generate(10, (rowIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: List.generate(4, (colIndex) {
                      final random = Random(rowIndex * 4 + colIndex);
                      final flex = random.nextInt(3) + 1;
                      final color = Colors
                          .primaries[random.nextInt(Colors.primaries.length)];

                      return Expanded(
                        flex: flex,
                        child: Container(
                          height: 80,
                          margin: EdgeInsets.only(
                            right: colIndex == 3 ? 0 : 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${rowIndex * 4 + colIndex + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: NativeGlassNavBar(
        key: ValueKey(_refreshKey),
        tabs: _tabs,
        actionButton: _isActionButtonEnabled
            ? TabBarActionButton(
                symbol: _actionButtonSymbol,
                onTap: () {
                  debugPrint('Action button tapped');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Action button tapped')),
                  );
                },
              )
            : null,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // tintColor: _tintColor,
      ),
    );
  }
}

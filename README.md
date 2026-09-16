# native_glass_navbar

A Flutter plugin that brings the native iOS Liquid Glass style navigation bar to your Flutter apps.

This package uses [platform views and method channels](https://docs.flutter.dev/platform-integration/ios/platform-views) to render the actual native iOS `UITabBar`. This means no more of that uncanny valley effect that you often get with custom Flutter implementations.

Oh yeah, it also doesn't have any 3rd party dependencies!

## **Demos** <br />
![output](https://github.com/user-attachments/assets/d7691c1b-5eef-451d-b18f-4d118ca3e8f2)
![output-items-bg](https://github.com/user-attachments/assets/5bbc0358-0e85-4604-89db-96eb68806053)

## Features

- **Native look and feel**: Probably because it is native 😉.
- **Dark Mode & Theming**: Automatically matches system themes and uses your app's primary color.
- **Action Button**: Add a floating action button for your main app actions.
- **SF Symbols**: Use any [SF Symbol](https://developer.apple.com/sf-symbols/) for icons.
- **Fallback Support**: Optionally define a fallback widget for Android or older iOS versions.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
    native_glass_navbar: ^1.1.0
```

## Requirements

- Build iOS apps with Xcode 27 or later.
- The example uses Flutter 3.47.4, pinned with FVM, and Swift Package Manager.

## Usage

Import the package:

```dart
import 'package:native_glass_navbar/native_glass_navbar.dart';
```

### Basic Implementation

```dart
NativeGlassNavBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
  tabs: const [
    NativeGlassNavBarItem(label: 'Home', symbol: 'house'),
    NativeGlassNavBarItem(label: 'Search', symbol: 'magnifyingglass'),
    NativeGlassNavBarItem(label: 'Settings', symbol: 'gear'),
  ],
)
```

### With Action Button

You can add a action button (e.g., for a "New Post" action). Note that when an action button is present, the maximum number of tabs is 4.

_yes I'm aware this is not the recommended design pattern but I like it soooooooo..._

```dart
NativeGlassNavBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  actionButton: TabBarActionButton(
    symbol: 'plus',
    onTap: () {
      print('Action button tapped!');
    },
  ),
  tabs: const [
    NativeGlassNavBarItem(label: 'Home', symbol: 'house'),
    NativeGlassNavBarItem(label: 'Profile', symbol: 'person'),
  ],
)
```

### Handling Unsupported Platforms

Since this plugin relies on native iOS APIs, it will not render the glass effect on Android or older iOS versions. You can provide a `fallback` widget (like a standard `BottomNavigationBar`) for these cases.

```dart
NativeGlassNavBar(
  // ... other properties
  fallback: BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: (index) => setState(() => _currentIndex = index),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ],
  ),
)
```

## API Reference

### NativeGlassNavBar

| Parameter      | Type                          | Description                                                                      |
| -------------- | ----------------------------- | -------------------------------------------------------------------------------- |
| `tabs`         | `List<NativeGlassNavBarItem>` | List of tabs to display. Max 5 (or 4 with action button).                        |
| `currentIndex` | `int`                         | The index of the currently selected tab.                                         |
| `onTap`        | `ValueChanged<int>`           | Callback when a tab is selected.                                                 |
| `actionButton` | `TabBarActionButton?`         | Optional action button.                                                          |
| `tintColor`    | `Color?`                      | Color of the selected item. Defaults to `Theme.of(context).colorScheme.primary`. |
| `fallback`     | `Widget?`                     | Widget to display if the platform is not supported.                              |

### NativeGlassNavBarItem

| Parameter | Type     | Description                                                                                          |
| --------- | -------- | ---------------------------------------------------------------------------------------------------- |
| `label`   | `String` | Text label for the tab.                                                                              |
| `symbol`  | `String` | [SF Symbol](https://developer.apple.com/sf-symbols/) name for the icon (e.g., 'house.fill', 'gear'). |

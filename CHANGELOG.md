## 2.0.0

- **Breaking:** Migrated the Dart implementation to Flutter's standalone
  `material_ui` package so decoupled Material and Cupertino apps share theme
  brightness and primary-color updates automatically.
- Raised the minimum supported versions to Flutter 3.44 and Dart 3.12.
- Migrated the bundled example app to `material_ui`.
- Apps using Flutter's legacy in-framework Material or Cupertino libraries
  should remain on 1.x until they migrate to the standalone UI packages.

## 1.2.0

- Added native tab badges through `NativeGlassNavBarItem.badgeValue`, including in-place updates and an interactive example.
- Added optional selected-state SF Symbols for tab items.
- Preserved native tab taps and selection while updating tab configuration in place.

## 1.1.0

- Restored the separate trailing action button on iOS 27 using `UITab` and `prominentTabIdentifier`, removing the incorrect Search label.
- Updated tab labels and icons in place and skipped redundant native configuration updates to reduce unnecessary UI work.
- Synchronized Flutter theme changes with the native bar and cleaned up method-channel handlers when the widget is disposed.
- Fixed Swift compilation errors and added the explicit SwiftPM `FlutterFramework` dependency.
- Migrated the example to Flutter 3.47.4, Swift Package Manager, and the Flutter scene lifecycle; refreshed its widget and native configuration tests.
- iOS builds now require Xcode 27 or later. The existing rendering path remains available on earlier iOS runtimes.

## 1.0.3

- Added Swift Package Manager support for iOS while retaining CocoaPods compatibility.
- Shared native sources and the privacy manifest between both build systems.

## 1.0.2

- Fixed an issue where tab bar would briefly flash the wrong color when app theme differed from system theme.
- Added support for custom image asset icons in tab bar items and action buttons.
- Added an example screen demonstrating custom icon assets.

## 1.0.1

- Added documentation for public API members.
- Enabled `public_member_api_docs` lint rule.

## 1.0.0

- Initial release of native_glass_navbar Flutter plugin

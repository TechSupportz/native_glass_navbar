## 1.1.0-dev.1

- Added `iconData` field to `NativeGlassNavBarItem` and `TabBarActionButton`. Pass any Flutter `IconData` (Lucide, Material, Cupertino, custom icon fonts) and the plugin rasterises it on-the-fly into a UIKit template image. SF Symbols still work — supply whichever fits.
- `symbol` is now optional on both types; one of `symbol` or `iconData` must be provided.
- New top-level helper `rasteriseIconData(IconData, {size})` exposed for tests and advanced use.
- iOS: icons resolved via new bytes-aware path that preserves template tinting for selected/unselected states.

## 1.0.2

- Fixed an issue where tab bar would briefly flash the wrong color when app theme differed from system theme.
- Added support for custom image asset icons in tab bar items and action buttons.
- Added an example screen demonstrating custom icon assets.

## 1.0.1

- Added documentation for public API members.
- Enabled `public_member_api_docs` lint rule.

## 1.0.0

- Initial release of native_glass_navbar Flutter plugin

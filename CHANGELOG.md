## 1.3.0-dev.1

- New `NativeGlassPill` widget: capsule-shaped native glass badge with optional leading icon. Pass `onTap` for the iOS 26 interactive `UIButton.Configuration.glass()` (or `.prominentGlass()` via `prominent: true`); omit it for a static decoration backed by `UIVisualEffectView(.systemMaterial)`. Same `symbol` / `iconData` API as the rest of the kit.

## 1.2.0-dev.2

- `NativeGlassButton` now uses `UIButton.Configuration.glass()` on iOS 26+, opting into UIKit's interactive Liquid Glass treatment: press-down scale, spring return, and material refraction shift are handled by the OS instead of a static blur. iOS 15–25 unchanged (still the systemMaterial fallback).

## 1.2.0-dev.1

- New `NativeGlassButton` widget: a circular, natively-rendered icon button with a Liquid Glass backdrop on iOS 26+ and a system-material blur fallback on iOS 15–25. Accepts the same `symbol` / `iconData` pair as `NativeGlassNavBarItem`. Wrap in `SizedBox` (or any constraint) to size it.
- Extracted shared icon resolution into `IconResolver` (Swift) so future glass primitives reuse the same bytes/symbol/asset fallback chain.

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

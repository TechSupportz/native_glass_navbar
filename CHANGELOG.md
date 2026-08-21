## 1.0.2+1

- Added an optional selected symbol for native tab bar items.
- Forwarded gestures eagerly to the native UIKit view so taps preserve the
  Liquid Glass interaction.
- Updated tab symbols in place without rebuilding the native tab bar.
- Added selected-index validation and in-place label updates.
- Cleaned up method-channel handlers when the native view is disposed.
- Kept the fallback visible while Liquid Glass support is being resolved.

## 1.0.2

- Fixed an issue where tab bar would briefly flash the wrong color when app theme differed from system theme.
- Added support for custom image asset icons in tab bar items and action buttons.
- Added an example screen demonstrating custom icon assets.

## 1.0.1

- Added documentation for public API members.
- Enabled `public_member_api_docs` lint rule.

## 1.0.0

- Initial release of native_glass_navbar Flutter plugin

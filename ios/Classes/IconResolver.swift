import Flutter
import UIKit

/// Shared icon resolution for all native glass components.
///
/// Prefers rasterised PNG bytes from the Flutter side, then falls back to
/// an SF Symbol name, then a bundled asset name. Always returns a template
/// image so the host view's tint pipeline (selected = tintColor,
/// unselected = systemGray, etc.) applies uniformly across both paths.
enum IconResolver {
	/// Resolves an icon for display in a native UIKit control.
	///
	/// - Parameters:
	///   - symbol: SF Symbol name (or bundled asset name) used as a fallback.
	///   - bytes: PNG data rasterised on the Flutter side. Preferred when present.
	///   - scale: Decode scale to apply to `bytes`. The Flutter side rasterises
	///            at 3× the requested display point size, so `3.0` is the right
	///            default for any host control sized in points.
	static func resolve(symbol: String, bytes: Data?, scale: CGFloat = 3.0) -> UIImage? {
		if let data = bytes, let image = UIImage(data: data, scale: scale) {
			return image.withRenderingMode(.alwaysTemplate)
		}
		if !symbol.isEmpty {
			return (UIImage(systemName: symbol) ?? UIImage(named: symbol))?
				.withRenderingMode(.alwaysTemplate)
		}
		return nil
	}

	/// Parses an ARGB int (the format the Dart side ships colours in) into
	/// a `UIColor`. Lifted out of `TabBarConfig` so all configs can share it.
	static func uiColorFromARGB(_ argb: Int) -> UIColor {
		let a = CGFloat((argb >> 24) & 0xFF) / 255.0
		let r = CGFloat((argb >> 16) & 0xFF) / 255.0
		let g = CGFloat((argb >> 8) & 0xFF) / 255.0
		let b = CGFloat(argb & 0xFF) / 255.0
		return UIColor(red: r, green: g, blue: b, alpha: a)
	}
}

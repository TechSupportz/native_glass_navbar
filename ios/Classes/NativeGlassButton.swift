import Flutter
import UIKit

/// Factory for the circular native glass icon button.
class NativeGlassButtonFactory: NSObject, FlutterPlatformViewFactory {
	private var messenger: FlutterBinaryMessenger

	init(messenger: FlutterBinaryMessenger) {
		self.messenger = messenger
		super.init()
	}

	func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
		-> FlutterPlatformView
	{
		return NativeGlassButtonPlatformView(
			frame: frame,
			viewId: viewId,
			args: args,
			messenger: messenger
		)
	}

	func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
		return FlutterStandardMessageCodec.sharedInstance()
	}
}

struct GlassButtonConfig: Equatable {
	var symbol: String = ""
	var iconBytes: Data? = nil
	/// Tint applied to the icon. Defaults to the dynamic `.label` system colour.
	var iconColor: UIColor = .label
	var isDark: Bool = false

	init(from dict: [String: Any]?) {
		guard let dict = dict else { return }
		if let s = dict["symbol"] as? String { self.symbol = s }
		if let bytes = dict["iconBytes"] as? FlutterStandardTypedData {
			self.iconBytes = bytes.data
		}
		if let c = dict["iconColor"] as? NSNumber {
			self.iconColor = IconResolver.uiColorFromARGB(c.intValue)
		}
		if let d = dict["isDark"] as? Bool {
			self.isDark = d
		}
	}
}

/// Container that keeps its blur child circular as it resizes. The Dart
/// side controls the actual point size via the host `SizedBox`; this view
/// only owns the visual roundness.
private final class GlassContainerView: UIView {
	let blurView: UIVisualEffectView
	private let isDark: Bool

	init(isDark: Bool) {
		self.isDark = isDark
		let style: UIBlurEffect.Style =
			isDark ? .systemMaterialDark : .systemMaterialLight
		self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
		super.init(frame: .zero)

		backgroundColor = .clear
		// Soft shadow on the container — masksToBounds on the blur view
		// would otherwise clip it.
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = isDark ? 0.30 : 0.10
		layer.shadowRadius = 12
		layer.shadowOffset = CGSize(width: 0, height: 4)

		blurView.translatesAutoresizingMaskIntoConstraints = false
		blurView.layer.masksToBounds = true
		blurView.layer.borderColor =
			UIColor.white.withAlphaComponent(isDark ? 0.16 : 0.6).cgColor
		blurView.layer.borderWidth = 0.6
		addSubview(blurView)

		NSLayoutConstraint.activate([
			blurView.topAnchor.constraint(equalTo: topAnchor),
			blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
			blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
			blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) is not supported")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		// Keep both the blur clip and the container's shadow path in sync
		// with the live bounds. UIKit lays out the platform view to fill
		// the Flutter-side SizedBox, so this is the canonical source.
		let radius = min(bounds.width, bounds.height) / 2.0
		blurView.layer.cornerRadius = radius
		layer.shadowPath =
			UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
	}
}

/// A circular icon button hosted natively. Backed by a `UIVisualEffectView`
/// with a system-material blur — iOS 26+ automatically upgrades that backdrop
/// to Liquid Glass (true refraction + adaptive tinting). On iOS 15–25 the
/// same view renders the older frosted blur, so the recipe is one source
/// of truth across versions.
class NativeGlassButtonPlatformView: NSObject, FlutterPlatformView {
	private let container: GlassContainerView
	private let channel: FlutterMethodChannel
	private var config: GlassButtonConfig
	private let button: UIButton

	init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
		self.config = GlassButtonConfig(from: args as? [String: Any])
		self.channel = FlutterMethodChannel(
			name: "NativeGlassButton_\(viewId)",
			binaryMessenger: messenger
		)
		self.container = GlassContainerView(isDark: config.isDark)
		self.button = UIButton(type: .system)

		super.init()

		// Place the button on top of the blur, filling the container.
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		container.addSubview(button)
		NSLayoutConstraint.activate([
			button.topAnchor.constraint(equalTo: container.topAnchor),
			button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
		])

		applyConfig()

		channel.setMethodCallHandler { [weak self] call, result in
			self?.handle(call, result: result)
		}
	}

	func view() -> UIView { container }

	private func applyConfig() {
		button.tintColor = config.iconColor
		button.setImage(
			IconResolver.resolve(symbol: config.symbol, bytes: config.iconBytes),
			for: .normal
		)
	}

	@objc private func buttonTapped() {
		channel.invokeMethod("buttonPressed", arguments: nil)
	}

	private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		if call.method == "update", let dict = call.arguments as? [String: Any] {
			self.config = GlassButtonConfig(from: dict)
			applyConfig()
			result(nil)
		} else {
			result(FlutterMethodNotImplemented)
		}
	}
}

import Flutter
import UIKit

/// Factory for the native glass pill (capsule with optional icon + text).
class NativeGlassPillFactory: NSObject, FlutterPlatformViewFactory {
	private var messenger: FlutterBinaryMessenger

	init(messenger: FlutterBinaryMessenger) {
		self.messenger = messenger
		super.init()
	}

	func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
		-> FlutterPlatformView
	{
		return NativeGlassPillPlatformView(
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

struct GlassPillConfig: Equatable {
	var text: String = ""
	var symbol: String = ""
	var iconBytes: Data? = nil
	var foregroundColor: UIColor = .label
	var prominent: Bool = false
	var interactive: Bool = false
	var isDark: Bool = false

	init(from dict: [String: Any]?) {
		guard let dict = dict else { return }
		if let s = dict["text"] as? String { self.text = s }
		if let s = dict["symbol"] as? String { self.symbol = s }
		if let b = dict["iconBytes"] as? FlutterStandardTypedData { self.iconBytes = b.data }
		if let c = dict["foregroundColor"] as? NSNumber {
			self.foregroundColor = IconResolver.uiColorFromARGB(c.intValue)
		}
		if let p = dict["prominent"] as? Bool { self.prominent = p }
		if let i = dict["interactive"] as? Bool { self.interactive = i }
		if let d = dict["isDark"] as? Bool { self.isDark = d }
	}
}

/// Capsule with text + optional leading icon, rendered natively.
///
/// **iOS 26+ interactive** (`onTap` provided): `UIButton.Configuration.glass()`
/// — full interactive Liquid Glass with press animation.
/// **iOS 26+ static** (no `onTap`): `UIVisualEffectView(.systemMaterial)` host
/// + native label / image view. The material auto-upgrades; no interaction.
/// **iOS 15–25**: same UIVisualEffectView path for both — static frosted glass.
class NativeGlassPillPlatformView: NSObject, FlutterPlatformView {
	private let hostView: UIView
	private let channel: FlutterMethodChannel
	private var config: GlassPillConfig

	// Interactive (iOS 26+) path.
	private var button: UIButton?

	// Static path (iOS 15-25, OR iOS 26+ non-interactive).
	private var blurView: UIVisualEffectView?
	private var label: UILabel?
	private var imageView: UIImageView?

	init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
		let config = GlassPillConfig(from: args as? [String: Any])
		self.config = config
		self.channel = FlutterMethodChannel(
			name: "NativeGlassPill_\(viewId)",
			binaryMessenger: messenger
		)

		let useInteractiveGlass: Bool = {
			if #available(iOS 26.0, *) {
				return config.interactive  // local var, no self access before super.init
			}
			return false
		}()

		if useInteractiveGlass, #available(iOS 26.0, *) {
			var btnConfig =
				config.prominent
					? UIButton.Configuration.prominentGlass()
					: UIButton.Configuration.glass()
			btnConfig.cornerStyle = .capsule
			btnConfig.imagePadding = 6
			let b = UIButton(configuration: btnConfig)
			self.button = b
			self.hostView = UIView(frame: frame)
		} else {
			let host = PillBlurView(isDark: config.isDark)
			self.blurView = host
			self.hostView = host
		}

		super.init()

		buildHierarchy()
		applyConfig()

		channel.setMethodCallHandler { [weak self] call, result in
			self?.handle(call, result: result)
		}
	}

	func view() -> UIView { hostView }

	private func buildHierarchy() {
		if let button = button {
			button.translatesAutoresizingMaskIntoConstraints = false
			button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
			hostView.addSubview(button)
			NSLayoutConstraint.activate([
				button.topAnchor.constraint(equalTo: hostView.topAnchor),
				button.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
				button.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
				button.bottomAnchor.constraint(equalTo: hostView.bottomAnchor),
			])
			return
		}

		// Non-interactive path: blur view contains a horizontal stack of
		// (icon, label).
		guard let blurView = blurView else { return }
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.setContentHuggingPriority(.required, for: .horizontal)
		self.imageView = imageView

		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .footnote)
		label.adjustsFontForContentSizeCategory = true
		self.label = label

		let stack = UIStackView(arrangedSubviews: [imageView, label])
		stack.axis = .horizontal
		stack.spacing = 6
		stack.alignment = .center
		stack.translatesAutoresizingMaskIntoConstraints = false
		blurView.contentView.addSubview(stack)

		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 4),
			stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -4),
			stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 10),
			stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -10),
			imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 16),
			imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 16),
		])
	}

	private func applyConfig() {
		let icon = IconResolver.resolve(symbol: config.symbol, bytes: config.iconBytes)

		if let button = button, #available(iOS 26.0, *) {
			var btnConfig = button.configuration ?? UIButton.Configuration.glass()
			btnConfig.image = icon
			btnConfig.title = config.text
			btnConfig.baseForegroundColor = config.foregroundColor
			button.configuration = btnConfig
			return
		}

		label?.text = config.text
		label?.textColor = config.foregroundColor
		imageView?.image = icon
		imageView?.tintColor = config.foregroundColor
		imageView?.isHidden = (icon == nil)
	}

	@objc private func buttonTapped() {
		channel.invokeMethod("pillPressed", arguments: nil)
	}

	private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		if call.method == "update", let dict = call.arguments as? [String: Any] {
			self.config = GlassPillConfig(from: dict)
			applyConfig()
			result(nil)
		} else {
			result(FlutterMethodNotImplemented)
		}
	}
}

/// UIVisualEffectView subclass for the non-interactive pill path. Keeps
/// itself capsule-shaped as it resizes — the corner radius tracks the
/// shorter dimension.
private final class PillBlurView: UIVisualEffectView {
	init(isDark: Bool) {
		let style: UIBlurEffect.Style =
			isDark ? .systemMaterialDark : .systemMaterialLight
		super.init(effect: UIBlurEffect(style: style))
		layer.masksToBounds = true
		layer.borderColor =
			UIColor.white.withAlphaComponent(isDark ? 0.16 : 0.6).cgColor
		layer.borderWidth = 0.6
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) is not supported")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
	}
}

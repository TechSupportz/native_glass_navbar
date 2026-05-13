import Flutter
import UIKit

class NativeTabBarFactory: NSObject, FlutterPlatformViewFactory {
	private var messenger: FlutterBinaryMessenger

	init(messenger: FlutterBinaryMessenger) {
		self.messenger = messenger
		super.init()
	}

	func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
		-> FlutterPlatformView
	{
		return NativeTabBarPlatformView(
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

class NativeTabBarPlatformView: NSObject, FlutterPlatformView {
	private let controller: LiquidGlassTabBarController

	init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
		self.controller = LiquidGlassTabBarController(
			viewId: viewId,
			messenger: messenger,
			args: args
		)
		super.init()
	}

	func view() -> UIView {
		return controller.view
	}
}

struct TabBarConfig: Equatable {
	var labels: [String] = []
	var symbols: [String] = []
	/// PNG bytes for each tab icon, aligned with `symbols`. A nil entry
	/// means "use the SF symbol at the same index instead".
	var iconBytes: [Data?] = []
	var actionButtonSymbol: String = ""
	/// PNG bytes for the action-button icon, if provided.
	var actionButtonIconBytes: Data? = nil
	var hasActionButton: Bool = false
	var tintColor: UIColor = .systemBlue
	var selectedIndex: Int = 0
	var isDark: Bool = false

	init(from dict: [String: Any]?) {
		guard let dict = dict else { return }
		if let l = dict["labels"] as? [String] { self.labels = l }
		if let s = dict["symbols"] as? [String] { self.symbols = s }

		if let bytes = dict["iconBytes"] as? [Any] {
			self.iconBytes = bytes.map { entry in
				if let typed = entry as? FlutterStandardTypedData {
					return typed.data
				}
				return nil
			}
		}

		if let action = dict["actionButtonSymbol"] as? String {
			self.actionButtonSymbol = action
		}
		if let actionBytes = dict["actionButtonIconBytes"] as? FlutterStandardTypedData {
			self.actionButtonIconBytes = actionBytes.data
		}

		// Backwards compatible: if `hasActionButton` is missing, infer it
		// from the symbol being non-empty (the v1.0.x contract).
		if let flag = dict["hasActionButton"] as? Bool {
			self.hasActionButton = flag
		} else {
			self.hasActionButton = !self.actionButtonSymbol.isEmpty
		}

		if let colorInt = dict["tintColor"] as? NSNumber {
			self.tintColor = TabBarConfig.uiColorFromARGB(colorInt.intValue)
		}
		if let idx = dict["selectedIndex"] as? Int {
			self.selectedIndex = idx
		}
		if let isDark = dict["isDark"] as? Bool {
			self.isDark = isDark
		}
	}

	func structuralChange(from other: TabBarConfig) -> Bool {
		return labels.count != other.labels.count
			|| symbols.count != other.symbols.count
			|| iconBytes.count != other.iconBytes.count
			|| hasActionButton != other.hasActionButton
	}

	private static func uiColorFromARGB(_ argb: Int) -> UIColor {
		let a = CGFloat((argb >> 24) & 0xFF) / 255.0
		let r = CGFloat((argb >> 16) & 0xFF) / 255.0
		let g = CGFloat((argb >> 8) & 0xFF) / 255.0
		let b = CGFloat(argb & 0xFF) / 255.0
		return UIColor(red: r, green: g, blue: b, alpha: a)
	}
}

class LiquidGlassTabBarController: UITabBarController, UITabBarControllerDelegate {
	private let channel: FlutterMethodChannel
	private var config: TabBarConfig
	private var currentAppearanceIsDark: Bool

	init(viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
		self.channel = FlutterMethodChannel(
			name: "NativeTabBar_\(viewId)",
			binaryMessenger: messenger
		)
		self.config = TabBarConfig(from: args as? [String: Any])
		self.currentAppearanceIsDark = config.isDark
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .clear
		self.view.isOpaque = false
		self.delegate = self
		overrideUserInterfaceStyle = config.isDark ? .dark : .light

		configureAppearance()
		performFullRebuild()

		channel.setMethodCallHandler { [weak self] call, result in
			self?.handle(call, result: result)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.view.backgroundColor = .clear
	}

	private func configureAppearance() {
		let appearance = UITabBarAppearance()
		appearance.configureWithDefaultBackground()
		appearance.backgroundColor = .clear
		appearance.shadowColor = .clear
		appearance.backgroundEffect = UIBlurEffect(style: config.isDark ? .dark : .light)

		let itemAppearance = UITabBarItemAppearance()
		itemAppearance.normal.iconColor = .systemGray
		itemAppearance.selected.iconColor = config.tintColor

		appearance.stackedLayoutAppearance = itemAppearance
		appearance.inlineLayoutAppearance = itemAppearance
		appearance.compactInlineLayoutAppearance = itemAppearance

		tabBar.standardAppearance = appearance
		if #available(iOS 15.0, *) {
			tabBar.scrollEdgeAppearance = appearance
		}

		tabBar.isTranslucent = true
		tabBar.tintColor = config.tintColor
	}

	private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		if call.method == "update", let dict = call.arguments as? [String: Any] {
			let newConfig = TabBarConfig(from: dict)
			let oldConfig = self.config

			if newConfig.structuralChange(from: oldConfig) {
				self.config = newConfig
				performFullRebuild()  // Destructive
			} else {
				// Light updates (in-place).
				self.config = newConfig

				updateSelectionAndColors()

				// Action-button icon swap.
				let actionSymbolChanged =
					oldConfig.actionButtonSymbol != newConfig.actionButtonSymbol
				let actionBytesChanged =
					oldConfig.actionButtonIconBytes != newConfig.actionButtonIconBytes
				if actionSymbolChanged || actionBytesChanged {
					updateActionIconInPlace()
				}

				// Tab icon swap (bytes only — symbols are static once mounted).
				if oldConfig.iconBytes != newConfig.iconBytes {
					updateTabIconsInPlace()
				}
			}

			result(nil)
		} else {
			result(FlutterMethodNotImplemented)
		}
	}

	// MARK: - Icon resolution

	/// Resolves an icon from either raw PNG bytes (preferred) or an SF Symbol
	/// name. Returns a template image so UIKit can tint it via the bar's
	/// `tintColor` for the selected state and `systemGray` for the normal
	/// state — matching the SF Symbol rendering path.
	private func resolveIcon(symbol: String, bytes: Data?) -> UIImage? {
		if let data = bytes, let image = UIImage(data: data) {
			return image.withRenderingMode(.alwaysTemplate)
		}
		if !symbol.isEmpty {
			return (UIImage(systemName: symbol) ?? UIImage(named: symbol))?
				.withRenderingMode(.alwaysTemplate)
		}
		return nil
	}

	// Updates the action-button icon without destroying the TabBarItem.
	private func updateActionIconInPlace() {
		guard let vcs = self.viewControllers else { return }
		if let actionVC = vcs.first(where: { $0.tabBarItem.tag == 99 }) {
			actionVC.tabBarItem.image = resolveIcon(
				symbol: config.actionButtonSymbol,
				bytes: config.actionButtonIconBytes
			)
		}
	}

	private func updateTabIconsInPlace() {
		guard let vcs = self.viewControllers else { return }
		for (i, vc) in vcs.enumerated() where vc.tabBarItem.tag != 99 {
			let symbol = i < config.symbols.count ? config.symbols[i] : ""
			let bytes = i < config.iconBytes.count ? config.iconBytes[i] : nil
			vc.tabBarItem.image = resolveIcon(symbol: symbol, bytes: bytes)
		}
	}

	private func performFullRebuild() {
		var controllers: [UIViewController] = []
		let count = max(config.labels.count, config.symbols.count)

		// Standard tabs.
		for i in 0..<count {
			let dummyVC = UIViewController()
			dummyVC.view.backgroundColor = .clear

			let symbolName = i < config.symbols.count ? config.symbols[i] : ""
			let label = i < config.labels.count ? config.labels[i] : ""
			let bytes = i < config.iconBytes.count ? config.iconBytes[i] : nil

			dummyVC.tabBarItem = UITabBarItem(
				title: label,
				image: resolveIcon(symbol: symbolName, bytes: bytes),
				tag: i
			)
			controllers.append(dummyVC)
		}

		// Action button.
		if config.hasActionButton {
			let actionVC = UIViewController()
			actionVC.view.backgroundColor = .clear

			let item = UITabBarItem(tabBarSystemItem: .search, tag: 99)
			item.image = resolveIcon(
				symbol: config.actionButtonSymbol,
				bytes: config.actionButtonIconBytes
			)

			actionVC.tabBarItem = item
			controllers.append(actionVC)
		}

		self.setViewControllers(controllers, animated: false)
		updateSelectionAndColors()
	}

	private func updateSelectionAndColors() {
		let needsAppearanceUpdate =
			tabBar.tintColor != config.tintColor
			|| currentAppearanceIsDark != config.isDark

		if needsAppearanceUpdate {
			tabBar.tintColor = config.tintColor
			currentAppearanceIsDark = config.isDark
			overrideUserInterfaceStyle = config.isDark ? .dark : .light
			configureAppearance()
		}

		if self.selectedIndex != config.selectedIndex {
			if let vcs = self.viewControllers,
				config.selectedIndex < vcs.count,
				vcs[config.selectedIndex].tabBarItem.tag != 99
			{
				self.selectedIndex = config.selectedIndex
			}
		}
	}

	// MARK: - Delegate
	func tabBarController(
		_ tabBarController: UITabBarController,
		shouldSelect viewController: UIViewController
	) -> Bool {
		if viewController.tabBarItem.tag == 99 {
			channel.invokeMethod("actionButtonPressed", arguments: nil)
			return false
		}
		return true
	}

	func tabBarController(
		_ tabBarController: UITabBarController,
		didSelect viewController: UIViewController
	) {
		let tag = viewController.tabBarItem.tag
		if tag != 99 {
			config.selectedIndex = tag
			channel.invokeMethod("valueChanged", arguments: ["index": tag])
		}
	}
}

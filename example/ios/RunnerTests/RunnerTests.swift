import Flutter
import XCTest

@testable import native_glass_navbar

class RunnerTests: XCTestCase {
	func testTabConfigurationDecodesFromFlutterCodec() {
		let payload: [String: Any] = [
			"labels": ["Home", "Search"],
			"symbols": ["house", "magnifyingglass"],
			"actionButtonSymbol": "plus",
			"selectedIndex": 1,
		]
		let codec = FlutterStandardMessageCodec.sharedInstance()
		let decoded = codec.decode(codec.encode(payload)) as? [String: Any]
		let config = TabBarConfig(from: decoded)

		XCTAssertEqual(config.labels, ["Home", "Search"])
		XCTAssertEqual(config.symbols, ["house", "magnifyingglass"])
		XCTAssertEqual(config.actionButtonSymbol, "plus")
		XCTAssertEqual(config.selectedIndex, 1)
		XCTAssertEqual(config.standardItemCount, 2)
		XCTAssertTrue(config.hasActionButton)
	}

	func testStructuralChangesDependOnTabCountAndActionPresence() {
		let original = TabBarConfig(from: [
			"labels": ["Home"],
			"symbols": ["house"],
		])
		let updated = TabBarConfig(from: [
			"labels": ["Start"],
			"symbols": ["house.fill"],
		])
		let additionalTab = TabBarConfig(from: [
			"labels": ["Home", "Search"],
			"symbols": ["house", "magnifyingglass"],
		])
		let addedAction = TabBarConfig(from: [
			"labels": ["Home"],
			"symbols": ["house"],
			"actionButtonSymbol": "plus",
		])
		let changedAction = TabBarConfig(from: [
			"labels": ["Home"],
			"symbols": ["house"],
			"actionButtonSymbol": "pencil",
		])

		XCTAssertFalse(updated.structuralChange(from: original))
		XCTAssertTrue(additionalTab.structuralChange(from: original))
		XCTAssertTrue(addedAction.structuralChange(from: original))
		XCTAssertFalse(changedAction.structuralChange(from: addedAction))
	}
}

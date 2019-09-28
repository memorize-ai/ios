import XCTest

final class memorize_aiUITests: XCTestCase {
	func testLaunchPerformance() {
		guard #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) else { return }
		measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
			XCUIApplication().launch()
		}
	}
}

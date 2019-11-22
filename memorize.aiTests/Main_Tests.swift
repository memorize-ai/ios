@testable import memorize_ai

import XCTest

final class Main_Tests: XCTestCase {
	func testIntFormatted() {
		XCTAssertEqual(1000.formatted, "1k")
		XCTAssertEqual(10000.formatted, "10k")
		XCTAssertEqual(12345.formatted, "12.3k")
	}
	
	func testDoubleFormatted() {
		XCTAssertEqual(1000.46.formatted, "1k")
		XCTAssertEqual(10000.25.formatted, "10k")
		XCTAssertEqual(12345.05.formatted, "12.3k")
		XCTAssertEqual(123456.05.formatted, "123.5k")
	}
}

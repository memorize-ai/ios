@testable import memorize_ai

import XCTest

final class Main_Tests: XCTestCase {
	func test_intFormatted() {
		XCTAssertEqual(1000.formatted, "1k")
		XCTAssertEqual(10000.formatted, "10k")
		XCTAssertEqual(12345.formatted, "12.3k")
	}
	
	func test_doubleFormatted() {
		XCTAssertEqual(1000.46.formatted, "1k")
		XCTAssertEqual(10000.25.formatted, "10k")
		XCTAssertEqual(12345.05.formatted, "12.3k")
		XCTAssertEqual(123456.05.formatted, "123.5k")
	}
	
	func test_sortArray() {
		XCTAssertEqual([1, 3, 2, 1].sorted(by: \.self), [1, 1, 2, 3])
		XCTAssertEqual([1, 3, 4, 2].sorted(by: \.self, with: >), [4, 3, 2, 1])
	}
	
	func test_trimmed() {
		XCTAssertEqual("abc ".trimmed, "abc")
		XCTAssertTrue(" ".isTrimmedEmpty)
		XCTAssertFalse("a".isTrimmedEmpty)
	}
	
	func test_deckSlug() {
		print(Deck.createSlug(forName: "This is a deck name"))
	}
}

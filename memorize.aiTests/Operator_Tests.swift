@testable import memorize_ai

import XCTest

final class Operator_Tests: XCTestCase {
	func testTilde() {
		let decks = [
			Deck(id: "1"),
			Deck(id: "2"),
			Deck(id: "3")
		]
		XCTAssertEqual(["1", "2", "3"], decks.map(~\.id))
	}
}

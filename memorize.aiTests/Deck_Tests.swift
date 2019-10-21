@testable import memorize_ai

import XCTest

final class Deck_Tests: XCTestCase {
	func testEquatable() {
		let deckA1 = Deck(id: "0")
		let deckA2 = Deck(id: "0")
		XCTAssertEqual(deckA1, deckA2)
		
		let deckB1 = Deck(id: "0")
		let deckB2 = Deck(id: "1")
		XCTAssertNotEqual(deckB1, deckB2)
	}
}

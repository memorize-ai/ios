final class Deck: Identifiable, Equatable {
	let id: String
	
	init(id: String) {
		self.id = id
	}
	
	static func == (lhs: Deck, rhs: Deck) -> Bool {
		lhs.id == rhs.id
	}
}

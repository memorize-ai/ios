final class Card: Identifiable, Equatable {
	let id: String
	
	init(id: String) {
		self.id = id
	}
	
	static func == (lhs: Card, rhs: Card) -> Bool {
		lhs.id == rhs.id
	}
}

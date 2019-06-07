var savedCards = [SavedCard]()

class SavedCard {
	let id: String?
	var front: String
	var back: String
	
	init(id: String?, front: String, back: String) {
		self.id = id
		self.front = front
		self.back = back
	}
	
	static func get(_ id: String) -> SavedCard? {
		return savedCards.first { $0.id == id }
	}
}

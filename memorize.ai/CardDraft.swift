import Firebase

var cardDrafts = [CardDraft]()

class CardDraft {
	let id: String
	let deckId: String
	let cardId: String?
	let type: CardDraftType
	var front: String
	var back: String
	
	init(id: String, deckId: String, cardId: String?, front: String, back: String) {
		self.id = id
		self.deckId = deckId
		self.cardId = cardId
		self.front = front
		self.back = back
		self.type = cardId == nil ? .new : .edit
	}
	
	var deck: Deck? {
		return Deck.get(deckId)
	}
	
	var card: Card? {
		guard let cardId = cardId else { return nil }
		return Card.get(cardId, deckId: deckId)
	}
	
	static func get(_ id: String) -> CardDraft? {
		return cardDrafts.first { $0.id == id }
	}
	
	static func get(deckId: String) -> CardDraft? {
		return cardDrafts.first { $0.deckId == deckId }
	}
	
	static func get(cardId: String) -> CardDraft? {
		return cardDrafts.first { $0.cardId == cardId }
	}
	
	func update(_ snapshot: DocumentSnapshot) {
		front = snapshot.get("front") as? String ?? front
		back = snapshot.get("back") as? String ?? back
	}
}

enum CardDraftType {
	case new
	case edit
}

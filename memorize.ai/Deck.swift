import UIKit

var decks = [Deck]()

class Deck {
	let id: String
	var image: UIImage?
	var name: String
	var description: String
	var isPublic: Bool
	var count: Int
	var mastered: Int
	var creator: String
	var owner: String
	var permissions: [Permission]
	var cards: [Card]
	
	init(id: String, image: UIImage?, name: String, description: String, isPublic: Bool, count: Int, mastered: Int, creator: String, owner: String, permissions: [Permission], cards: [Card]) {
		self.id = id
		self.image = image
		self.name = name
		self.description = description
		self.isPublic = isPublic
		self.count = count
		self.mastered = mastered
		self.creator = creator
		self.owner = owner
		self.permissions = permissions
		self.cards = cards
	}
	
	static func view(_ deckId: String) {
		functions.httpsCallable("viewDeck").call(["deckId": deckId]) { _, _ in }
	}
	
	static func rate(_ deckId: String, rating: DeckRating, completion: @escaping (Error?) -> Void) {
		functions.httpsCallable("rateDeck").call(["deckId": deckId]) { _, error in
			completion(error)
		}
	}
	
	static func id(_ t: String) -> Int? {
		for i in 0..<decks.count {
			if decks[i].id == t {
				return i
			}
		}
		return nil
	}
	
	static func allDue() -> [Card] {
		return decks.flatMap { return $0.cards.filter { return $0.isDue() } }
	}
	
	func card(id t: String) -> Int? {
		for i in 0..<cards.count {
			if cards[i].id == t {
				return i
			}
		}
		return nil
	}
	
	func allDue() -> [Card] {
		return cards.filter { return $0.isDue() }
	}
	
	func rate(_ rating: DeckRating, completion: @escaping (Error?) -> Void) {
		Deck.rate(id, rating: rating, completion: completion)
	}
}

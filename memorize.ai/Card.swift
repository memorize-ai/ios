import Foundation
import Firebase

class Card {
	let id: String
	var front: String
	var back: String
	let created: Date
	var updated: Date
	var likes: Int
	var dislikes: Int
	var count: Int
	var correct: Int
	var e: Double
	var streak: Int
	var mastered: Bool
	var last: CardLast?
	var next: Date
	var history: [History]
	let deck: String
	
	init(id: String, front: String, back: String, created: Date, updated: Date, likes: Int, dislikes: Int, count: Int, correct: Int, e: Double, streak: Int, mastered: Bool
		, last: CardLast?, next: Date, history: [History], deck: String) {
		self.id = id
		self.front = front
		self.back = back
		self.created = created
		self.updated = updated
		self.likes = likes
		self.dislikes = dislikes
		self.count = count
		self.correct = correct
		self.e = e
		self.streak = streak
		self.mastered = mastered
		self.last = last
		self.next = next
		self.history = history
		self.deck = deck
	}
	
	var getDeck: Deck? {
		return Deck.get(deck)
	}
	
	var text: (front: String, back: String) {
		return (front, back)
	}
	
	var draft: CardDraft? {
		return CardDraft.get(cardId: id)
	}
	
	var hasDraft: Bool {
		return draft != nil
	}
	
	convenience init(id: String, front: String, back: String, created: Date, updated: Date, likes: Int, dislikes: Int, deck: String) {
		self.init(id: id, front: front, back: back, created: created, updated: updated, likes: likes, dislikes: dislikes, count: 0, correct: 0, e: 0, streak: 0, mastered: false, last: nil, next: Date(), history: [], deck: deck)
	}
	
	static func all() -> [Card] {
		return decks.flatMap { $0.cards }
	}
	
	static func poll() {
		Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			if !Deck.allDue().isEmpty {
				ChangeHandler.call(.cardDue)
			}
		}
	}
	
	static func sortDue(_ cards: [Card]) -> [Card] {
		return cards.sorted { $0.next.timeIntervalSinceNow < $1.next.timeIntervalSinceNow }
	}
	
	static func get(_ id: String, deckId: String) -> Card? {
		return Deck.get(deckId)?.cards.first { $0.id == id }
	}
	
	func isDue() -> Bool {
		return next.timeIntervalSinceNow <= 0
	}
	
	func update(_ snapshot: DocumentSnapshot, type: CardUpdateType) {
		switch type {
		case .card:
			front = snapshot.get("front") as? String ?? front
			back = snapshot.get("back") as? String ?? back
			updated = snapshot.getDate("updated") ?? updated
			likes = snapshot.get("likes") as? Int ?? likes
			dislikes = snapshot.get("dislikes") as? Int ?? dislikes
		case .user:
			count = snapshot.get("count") as? Int ?? count
			correct = snapshot.get("correct") as? Int ?? correct
			e = snapshot.get("e") as? Double ?? e
			streak = snapshot.get("streak") as? Int ?? streak
			mastered = snapshot.get("mastered") as? Bool ?? mastered
			last = CardLast(snapshot) ?? last
			next = snapshot.getDate("next") ?? next
		}
	}
	
	func reset() {
		count = 0
		correct = 0
		e = 2.5
		streak = 0
		mastered = false
		last = nil
		next = Date()
	}
}

class CardRating {
	let id: String
	var rating: CardRatingType
	var date: Date
	
	init(id: String, rating: CardRatingType, date: Date) {
		self.id = id
		self.rating = rating
		self.date = date
	}
}

class CardLast {
	let id: String
	let date: Date
	let rating: Int
	let elapsed: Int
	
	init(id: String, date: Date, rating: Int, elapsed: Int) {
		self.id = id
		self.date = date
		self.rating = rating
		self.elapsed = elapsed
	}
	
	init?(_ snapshot: DocumentSnapshot) {
		guard let last = snapshot.get("last") as? [String : Any] else { return nil }
		id = last["id"] as? String ?? "Error"
		date = (last["date"] as? Timestamp)?.dateValue() ?? Date()
		rating = last["rating"] as? Int ?? 0
		elapsed = last["elapsed"] as? Int ?? 0
	}
}

enum CardRatingType: Int {
	case dislike = -1
	case none = 0
	case like = 1
	
	init(_ number: Int) {
		switch number {
		case -1:
			self = .dislike
		case 1:
			self = .like
		default:
			self = .none
		}
	}
}

enum CardUpdateType {
	case card
	case user
}

enum CardSide: String {
	case front = "front"
	case back = "back"
	
	var uppercased: String {
		return rawValue.uppercased()
	}
}

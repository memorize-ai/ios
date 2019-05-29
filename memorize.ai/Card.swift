import Foundation

class Card {
	let id: String
	var front: String
	var back: String
	var count: Int
	var correct: Int
	var streak: Int
	var mastered: Bool
	var last: Last?
	var next: Date
	var history: [History]
	let deck: String
	
	init(id: String, front: String, back: String, count: Int, correct: Int, streak: Int, mastered: Bool, last: Last?, next: Date, history: [History], deck: String) {
		self.id = id
		self.front = front
		self.back = back
		self.count = count
		self.correct = correct
		self.streak = streak
		self.mastered = mastered
		self.last = last
		self.next = next
		self.history = history
		self.deck = deck
	}
	
	class Last {
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
	}
	
	static func all() -> [Card] {
		return decks.flatMap { return $0.cards }
	}
	
	static func poll() {
		Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
			if !Deck.allDue().isEmpty {
				ChangeHandler.call(.cardDue)
			}
		}
	}
	
	static func sortDue(_ cards: [Card]) -> [Card] {
		return cards.sorted { return $0.next.timeIntervalSinceNow < $1.next.timeIntervalSinceNow }
	}
	
	func isDue() -> Bool {
		return next.timeIntervalSinceNow <= 0
	}
}

enum CardRating {
	case none
	case dislike
	case like
}

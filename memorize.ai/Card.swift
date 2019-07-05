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
	
	convenience init(id: String, front: String, back: String, created: Date, updated: Date, likes: Int, dislikes: Int, deck: String) {
		self.init(id: id, front: front, back: back, created: created, updated: updated, likes: likes, dislikes: dislikes, count: 0, correct: 0, e: DEFAULT_E, streak: 0, mastered: false, last: nil, next: Date(), history: [], deck: deck)
	}
	
	static var all: [Card] {
		return decks.flatMap { $0.cards }
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
	
	var rating: CardRating? {
		return CardRating.get(id)
	}
	
	var hasRating: Bool {
		return rating != nil
	}
	
	var ratingType: CardRatingType {
		return rating?.rating ?? .none
	}
	
	static func escape(_ text: String) -> String {
		return convertFileUrls(text).replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: #"<\s*audio\s*>.*<\s*/\s*audio\s*>\n*"#, with: "", options: .regularExpression)
	}
	
	static func playAudio(_ text: String, completion: @escaping (Bool) -> Void = { _ in }) {
		Audio.play(urls: getAudioUrls(text), completion: completion)
	}
	
	static func getAudioUrls(_ text: String) -> [URL] {
		return convertFileUrls(text).match(#"<\s*audio\s*>(.*)<\s*/\s*audio\s*>\n*"#).compactMap {
			guard let string = $0[safe: 1] else { return nil }
			return URL(string: string.trim())
		}
	}
	
	static func convertFileUrls(_ text: String) -> String {
		var text = text
		for match in text.match(#"file://([^/\s]+)/([^/\s]+)/([^/\s]+)"#) where match.count >= 4 {
			text = text.replacingOccurrences(of: match[0], with: "https://firebasestorage.googleapis.com/v0/b/uploads.memorize.ai/o/\(match[1])%\(match[2])?alt=media&token=\(match[3])")
		}
		return text
	}
	
	static func convertUrlToFile(_ text: String) -> String {
		guard let match = text.match(#"https://firebasestorage.googleapis.com/v0/b/uploads.memorize.ai/o/([^/\s]+)%([^/\s]+)?alt=media&token=([^/\s]+)"#).first, match.count >= 4 else { return text }
		return "file://\(match[1])/\(match[2])/\(match[3])"
	}
	
	static func poll() {
		Timer.scheduledTimer(withTimeInterval: CARD_POLL_INTERVAL, repeats: true) { _ in
			if !Deck.allDue().isEmpty {
				ChangeHandler.call(.cardDue)
			}
		}
	}
	
	static func sort(_ cards: [Card], by type: CardSortType) -> [Card] {
		switch type {
		case .due:
			return cards.sorted { $0.front < $1.front }
		case .front:
			return cards.sorted { $0.next.timeIntervalSinceNow < $1.next.timeIntervalSinceNow }
		}
	}
	
	static func get(_ id: String, deckId: String) -> Card? {
		return Deck.get(deckId)?.cards.first { $0.id == id }
	}
	
	static func rate(_ id: String, deckId: String, type: CardRatingType, completion: @escaping (Error?) -> Void = { _ in }) {
		functions.httpsCallable("rateCard").call(["deckId": deckId, "cardId": id, "rating": type.rawValue]) { completion($1) }
	}
	
	func playAudio(_ side: CardSide, completion: @escaping (Bool) -> Void = { _ in }) {
		Card.playAudio(side.text(for: self), completion: completion)
	}
	
	func getAudioUrls(_ side: CardSide) -> [URL] {
		return Card.getAudioUrls(side.text(for: self))
	}
	
	func hasAudio(_ side: CardSide) -> Bool {
		return !getAudioUrls(side).isEmpty
	}
	
	func rate(_ type: CardRatingType, completion: @escaping (Error?) -> Void = { _ in }) {
		Card.rate(id, deckId: deck, type: type, completion: completion)
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
		e = DEFAULT_E
		streak = 0
		mastered = false
		last = nil
		next = Date()
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
	
	func text(for card: Card) -> String {
		return self == .front ? card.front : card.back
	}
}

enum CardSortType {
	case due
	case front
}

import UIKit

var decks = [Deck]()

class Deck {
	let id: String
	var image: UIImage?
	var name: String
	var subtitle: String
	var description: String
	var isPublic: Bool
	var count: Int
	var views: DeckViews
	var downloads: DeckDownloads
	var ratings: DeckRatings
	var users: [DeckUser]
	var creator: String
	var owner: String
	var created: Date
	var updated: Date
	var permissions: [Permission]
	var cards: [Card]
	var mastered: Int
	
	init(id: String, image: UIImage?, name: String, subtitle: String, description: String, isPublic: Bool, count: Int, views: DeckViews, downloads: DeckDownloads, ratings: DeckRatings, users: [DeckUser], creator: String, owner: String, created: Date, updated: Date, permissions: [Permission], cards: [Card], mastered: Int) {
		self.id = id
		self.image = image
		self.name = name
		self.subtitle = subtitle
		self.description = description
		self.isPublic = isPublic
		self.count = count
		self.views = views
		self.downloads = downloads
		self.ratings = ratings
		self.users = users
		self.creator = creator
		self.owner = owner
		self.created = created
		self.updated = updated
		self.permissions = permissions
		self.cards = cards
		self.mastered = mastered
	}
	
	static func view(_ deckId: String) {
		functions.httpsCallable("viewDeck").call(["deckId": deckId]) { _, _ in }
	}
	
	static func rate(_ deckId: String, rating: Int, completion: @escaping (Error?) -> Void) {
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
	
	func rate(_ rating: Int, completion: @escaping (Error?) -> Void) {
		Deck.rate(id, rating: rating, completion: completion)
	}
}

class DeckViews {
	var total: Int
	var unique: Int
	
	init(total: Int, unique: Int) {
		self.total = total
		self.unique = unique
	}
}

class DeckDownloads {
	var total: Int
	var current: Int
	
	init(total: Int, current: Int) {
		self.total = total
		self.current = current
	}
}

class DeckRatings {
	var average: Double
	var all1: Int
	var all2: Int
	var all3: Int
	var all4: Int
	var all5: Int
	
	init(average: Double, all1: Int, all2: Int, all3: Int, all4: Int, all5: Int) {
		self.average = average
		self.all1 = all1
		self.all2 = all2
		self.all3 = all3
		self.all4 = all4
		self.all5 = all5
	}
}

class DeckUser {
	let id: String
	var past: Bool
	var current: Bool
	var rating: Int?
	var review: String?
	var date: Date?
	var cards: [CardRating]
	
	init(id: String, past: Bool, current: Bool, rating: Int?, review: String?, date: Date?, cards: [CardRating]) {
		self.id = id
		self.past = past
		self.current = current
		self.rating = rating
		self.review = review
		self.date = date
		self.cards = cards
	}
}

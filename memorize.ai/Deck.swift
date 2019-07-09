import UIKit
import Firebase

var allDecks = [Deck]()
var decks: [Deck] {
	return allDecks.filter { !$0.hidden }
}

class Deck {
	let id: String
	var hasImage: Bool
	var image: UIImage?
	var name: String
	var subtitle: String
	var description: String
	var tags: [String]
	var isPublic: Bool
	var count: Int
	var views: DeckViews
	var downloads: DeckDownloads
	var ratings: DeckRatings
	var users: [DeckUser]
	let creator: String
	var owner: String
	let created: Date
	var updated: Date
	var permissions: [Permission]
	var cards: [Card]
	var mastered: Int
	var role: Role
	var hidden: Bool
	
	init(id: String, hasImage: Bool, image: UIImage?, name: String, subtitle: String, description: String, tags: [String], isPublic: Bool, count: Int, views: DeckViews, downloads: DeckDownloads, ratings: DeckRatings, users: [DeckUser], creator: String, owner: String, created: Date, updated: Date, permissions: [Permission], cards: [Card], mastered: Int, role: Role, hidden: Bool) {
		self.id = id
		self.hasImage = hasImage
		self.image = image
		self.name = name
		self.subtitle = subtitle
		self.description = description
		self.tags = tags
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
		self.role = role
		self.hidden = hidden
	}
	
	var cardDraft: CardDraft? {
		return CardDraft.get(deckId: id)
	}
	
	var hasCardDraft: Bool {
		return cardDraft != nil
	}
	
	var rating: DeckRating? {
		return DeckRating.get(id)
	}
	
	var hasRating: Bool {
		return rating != nil
	}
	
	var ratingDraft: RatingDraft? {
		return RatingDraft.get(id)
	}
	
	var hasRatingDraft: Bool {
		return ratingDraft != nil
	}
	
	@discardableResult
	static func cache(_ id: String, image: UIImage?) -> UIImage? {
		Cache.new(.deck, key: id, image: image, format: .image)
		return image
	}
	
	static func imageFromCache(_ id: String) -> UIImage? {
		guard let cache = Cache.get(.deck, key: id) else { return nil }
		return cache.getImage() ?? DEFAULT_DECK_IMAGE
	}
	
	static func url(id: String) -> URL? {
		return URL(string: "https://memorize.ai/d/\(id)")
	}
	
	static func new(_ deckId: String, completion: @escaping (Error?) -> Void) {
		functions.httpsCallable("addDeck").call(["deckId": deckId]) { completion($1) }
	}
	
	static func view(_ deckId: String, completion: @escaping (Error?) -> Void = { _ in }) {
		functions.httpsCallable("viewDeck").call(["deckId": deckId]) { completion($1) }
	}
	
	static func rate(_ deckId: String, rating: Int, title: String?, review: String?, completion: @escaping (Error?) -> Void) {
		functions.httpsCallable("rateDeck").call(["deckId": deckId, "rating": rating, "title": title ?? "", "review": review ?? ""]) { completion($1) }
	}
	
	static func unrate(_ deckId: String, completion: @escaping (Error?) -> Void) {
		rate(deckId, rating: 0, title: nil, review: nil, completion: completion)
	}
	
	static func clearAllData(_ deckId: String, completion: @escaping (Error?) -> Void) {
		functions.httpsCallable("clearDeckData").call(["deckId": deckId]) { completion($1) }
	}
	
	static func delete(_ deckId: String, completion: @escaping (Error?) -> Void) {
		functions.httpsCallable("deleteDeck").call(["deckId": deckId]) { completion($1) }
	}
	
	static func getFromAll(_ id: String) -> Deck? {
		return allDecks.first { $0.id == id }
	}
	
	static func get(_ id: String) -> Deck? {
		return decks.first { $0.id == id }
	}
	
	static func has(_ id: String?) -> Bool {
		guard let id = id else { return false }
		return get(id) != nil
	}
	
	static func numberOfTagsInCommon(_ first: [String], _ second: [String]) -> Int {
		return first.count > second.count
			? first.filter { second.contains($0) }.count
			: second.filter { first.contains($0) }.count
	}
	
	static func allDue() -> [Card] {
		return decks.flatMap { $0.allDue() }
	}
	
	func allDue() -> [Card] {
		return cards.filter { $0.isDue() }
	}
	
	func rate(_ rating: Int, title: String?, review: String?, completion: @escaping (Error?) -> Void) {
		Deck.rate(id, rating: rating, title: title, review: review, completion: completion)
	}
	
	func unrate(completion: @escaping (Error?) -> Void) {
		Deck.unrate(id, completion: completion)
	}
	
	func clearAllData(completion: @escaping (Error?) -> Void) {
		Deck.clearAllData(id, completion: completion)
	}
	
	func update(_ snapshot: DocumentSnapshot, type: DeckUpdateType) {
		switch type {
		case .deck:
			hasImage = snapshot.get("hasImage") as? Bool ?? false
			name = snapshot.get("name") as? String ?? name
			subtitle = snapshot.get("subtitle") as? String ?? subtitle
			description = snapshot.get("description") as? String ?? description
			tags = snapshot.get("tags") as? [String] ?? tags
			isPublic = snapshot.get("public") as? Bool ?? isPublic
			count = snapshot.get("count") as? Int ?? count
			views = DeckViews(snapshot)
			downloads = DeckDownloads(snapshot)
			ratings = DeckRatings(snapshot)
			owner = snapshot.get("owner") as? String ?? owner
			updated = snapshot.getDate("updated") ?? updated
		case .user:
			mastered = snapshot.get("mastered") as? Int ?? mastered
			role = Role(snapshot.get("role") as? String)
			hidden = snapshot.get("hidden") as? Bool ?? hidden
		}
	}
}

class DeckViews {
	var total: Int
	var unique: Int
	
	init(total: Int, unique: Int) {
		self.total = total
		self.unique = unique
	}
	
	convenience init(_ snapshot: DocumentSnapshot) {
		self.init(snapshot.get("views") as? [String : Any] ?? [:])
	}
	
	convenience init(_ dictionary: [String : Any]) {
		self.init(
			total: dictionary["total"] as? Int ?? 0,
			unique: dictionary["unique"] as? Int ?? 0
		)
	}
}

class DeckDownloads {
	var total: Int
	var current: Int
	
	init(total: Int, current: Int) {
		self.total = total
		self.current = current
	}
	
	convenience init(_ snapshot: DocumentSnapshot) {
		self.init(snapshot.get("downloads") as? [String : Any] ?? [:])
	}
	
	convenience init(_ dictionary: [String : Any]) {
		self.init(
			total: dictionary["total"] as? Int ?? 0,
			current: dictionary["current"] as? Int ?? 0
		)
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
	
	convenience init(_ snapshot: DocumentSnapshot) {
		self.init(snapshot.get("ratings") as? [String : Any] ?? [:])
	}
	
	convenience init(_ dictionary: [String : Any]) {
		self.init(
			average: dictionary["average"] as? Double ?? 0,
			all1: dictionary["1"] as? Int ?? 0,
			all2: dictionary["2"] as? Int ?? 0,
			all3: dictionary["3"] as? Int ?? 0,
			all4: dictionary["4"] as? Int ?? 0,
			all5: dictionary["5"] as? Int ?? 0
		)
	}
	
	convenience init(searchResult: Algolia.SearchResult) {
		self.init(searchResult["ratings"] as? [String : Any] ?? [:])
	}
	
	var count: Int {
		return all1 + all2 + all3 + all4 + all5
	}
	
	func compare(with ratings: DeckRatings) -> Bool {
		return average == ratings.average ? count > ratings.count : average > ratings.average
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
	
	init(_ snapshot: DocumentSnapshot) {
		id = snapshot.documentID
		past = snapshot.get("past") as? Bool ?? false
		current = snapshot.get("current") as? Bool ?? false
		rating = snapshot.get("rating") as? Int
		review = snapshot.get("review") as? String
		date = snapshot.getDate("date")
		cards = []
	}
}

enum DeckUpdateType {
	case deck
	case user
}

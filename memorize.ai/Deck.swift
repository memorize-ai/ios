import UIKit
import Firebase
import CoreData

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
	let creator: String
	var owner: String
	let created: Date
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
	
	var cardDraft: CardDraft? {
		return CardDraft.get(deckId: id)
	}
	
	static func view(_ deckId: String) {
		functions.httpsCallable("viewDeck").call(["deckId": deckId]) { _, _ in }
	}
	
	static func rate(_ deckId: String, rating: Int, completion: @escaping (Error?) -> Void) {
		functions.httpsCallable("rateDeck").call(["deckId": deckId]) { _, error in
			completion(error)
		}
	}
	
	static func get(_ id: String) -> Deck? {
		return decks.first { $0.id == id }
	}
	
	static func allDue() -> [Card] {
		return decks.flatMap { $0.cards.filter { $0.isDue() } }
	}
	
	static func loadFromCoreData() {
		guard let managedDecks = try? (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext.fetch(NSFetchRequest<NSManagedObject>(entityName: "ManagedDeck")) else { return }
		for managedDeck in managedDecks {
			guard let id = managedDeck.value(forKey: "id") as? String, let name = managedDeck.value(forKey: "name") as? String, let subtitle = managedDeck.value(forKey: "subtitle") as? String, let description = managedDeck.value(forKey: "desc") as? String, let isPublic = managedDeck.value(forKey: "isPublic") as? Bool, let count = managedDeck.value(forKey: "count") as? Int32, let creator = managedDeck.value(forKey: "creator") as? String, let owner = managedDeck.value(forKey: "owner") as? String, let mastered = managedDeck.value(forKey: "mastered") as? Int32 else { continue }
			var image: UIImage?
			if let data = managedDeck.value(forKey: "image") as? Data {
				image = UIImage(data: data)
			}
			if let image = image, let deck = get(id) {
				deck.image = image
			} else {
				decks.append(Deck(
					id: id,
					image: image,
					name: name,
					subtitle: subtitle,
					description: description,
					isPublic: isPublic,
					count: Int(count),
					views: DeckViews(total: 0, unique: 0),
					downloads: DeckDownloads(total: 0, current: 0),
					ratings: DeckRatings(average: 0, all1: 0, all2: 0, all3: 0, all4: 0, all5: 0),
					users: [],
					creator: creator,
					owner: owner,
					created: Date(),
					updated: Date(),
					permissions: [],
					cards: [],
					mastered: Int(mastered)
				))
			}
		}
	}
	
	func allDue() -> [Card] {
		return cards.filter { $0.isDue() }
	}
	
	func rate(_ rating: Int, completion: @escaping (Error?) -> Void) {
		Deck.rate(id, rating: rating, completion: completion)
	}
	
	func update(_ snapshot: DocumentSnapshot, type: DeckUpdateType) {
		switch type {
		case .deck:
			name = snapshot.get("name") as? String ?? name
			subtitle = snapshot.get("subtitle") as? String ?? subtitle
			description = snapshot.get("description") as? String ?? description
			isPublic = snapshot.get("public") as? Bool ?? isPublic
			count = snapshot.get("count") as? Int ?? count
			views = DeckViews(snapshot)
			downloads = DeckDownloads(snapshot)
			ratings = DeckRatings(snapshot)
			owner = snapshot.get("owner") as? String ?? owner
			updated = snapshot.getDate("updated") ?? updated
		case .user:
			mastered = snapshot.get("mastered") as? Int ?? mastered
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
	
	init(_ snapshot: DocumentSnapshot) {
		let views = snapshot.get("views") as? [String : Any]
		total = views?["total"] as? Int ?? 0
		unique = views?["unique"] as? Int ?? 0
	}
}

class DeckDownloads {
	var total: Int
	var current: Int
	
	init(total: Int, current: Int) {
		self.total = total
		self.current = current
	}
	
	init(_ snapshot: DocumentSnapshot) {
		let downloads = snapshot.get("downloads") as? [String : Any]
		total = downloads?["total"] as? Int ?? 0
		current = downloads?["current"] as? Int ?? 0
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
	
	init(_ snapshot: DocumentSnapshot) {
		let ratings = snapshot.get("ratings") as? [String : Any]
		average = ratings?["average"] as? Double ?? 0
		all1 = ratings?["1"] as? Int ?? 0
		all2 = ratings?["2"] as? Int ?? 0
		all3 = ratings?["3"] as? Int ?? 0
		all4 = ratings?["4"] as? Int ?? 0
		all5 = ratings?["5"] as? Int ?? 0
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

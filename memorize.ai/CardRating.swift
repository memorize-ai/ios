import Foundation
import Firebase

var cardRatings = [CardRating]()

class CardRating {
	let deckId: String
	let id: String
	var rating: CardRatingType
	var date: Date
	
	init(deckId: String, id: String, rating: CardRatingType, date: Date) {
		self.deckId = deckId
		self.id = id
		self.rating = rating
		self.date = date
	}
	
	var deck: Deck? {
		return Deck.get(deckId)
	}
	
	var card: Card? {
		return Card.get(id, deckId: deckId)
	}
	
	static func get(_ id: String) -> CardRating? {
		return cardRatings.first { $0.id == id }
	}
	
	func update(_ snapshot: DocumentSnapshot) {
		rating = CardRatingType(snapshot.get("rating") as? Int ?? rating.rawValue)
		date = snapshot.getDate("date") ?? date
	}
}

enum CardRatingType: Int {
	case dislike = -1
	case none = 0
	case like = 1
	
	init(_ number: Int) {
		self = CardRatingType(rawValue: number) ?? .none
	}
}

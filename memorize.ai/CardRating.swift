import Foundation

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

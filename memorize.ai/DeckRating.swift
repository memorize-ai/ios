import Foundation
import Firebase

var deckRatings = [DeckRating]()

class DeckRating {
	let id: String
	var rating: Int
	var title: String
	var review: String
	var date: Date
	
	init(id: String, rating: Int, title: String, review: String, date: Date) {
		self.id = id
		self.rating = rating
		self.title = title
		self.review = review
		self.date = date
	}
	
	var deck: Deck? {
		return Deck.get(id)
	}
	
	var hasTitle: Bool {
		return !title.isEmpty
	}
	
	var hasReview: Bool {
		return !review.isEmpty
	}
	
	var draft: RatingDraft? {
		return RatingDraft.get(id)
	}
	
	static func get(_ id: String) -> DeckRating? {
		return deckRatings.first { $0.id == id }
	}
	
	func update(_ snapshot: DocumentSnapshot) {
		rating = snapshot.get("rating") as? Int ?? rating
		title = snapshot.get("title") as? String ?? title
		review = snapshot.get("review") as? String ?? review
		date = snapshot.getDate("date") ?? date
	}
}

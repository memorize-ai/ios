var deckRatings = [DeckRating]()

class DeckRating {
	let id: String
	var rating: Int
	var review: String
	
	init(id: String, rating: Int, review: String) {
		self.id = id
		self.rating = rating
		self.review = review
	}
	
	var deck: Deck? {
		return Deck.get(id)
	}
	
	var hasReview: Bool {
		return !review.isEmpty
	}
	
	var draft: RatingDraft? {
		return RatingDraft.get(id)
	}
}

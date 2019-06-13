import Firebase

var ratingDrafts = [RatingDraft]()

class RatingDraft {
	let id: String
	var rating: Int?
	var review: String?
	
	init(id: String, rating: Int?, review: String?) {
		self.id = id
		self.rating = rating
		self.review = review
	}
	
	var deck: Deck? {
		return Deck.get(id)
	}
	
	static func get(_ id: String) -> RatingDraft? {
		return ratingDrafts.first { $0.id == id }
	}
	
	func update(_ snapshot: DocumentSnapshot) {
		rating = snapshot.get("rating") as? Int
		review = snapshot.get("review") as? String
	}
}

import Firebase

var ratingDrafts = [RatingDraft]()

class RatingDraft {
	let id: String
	var rating: Int?
	var title: String?
	var review: String?
	
	init(id: String, rating: Int?, title: String?, review: String?) {
		self.id = id
		self.rating = rating
		self.title = title
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
		title = snapshot.get("title") as? String
		review = snapshot.get("review") as? String
	}
}

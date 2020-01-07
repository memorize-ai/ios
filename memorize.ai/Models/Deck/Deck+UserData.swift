import Foundation
import FirebaseFirestore

extension Deck {
	struct UserData: Hashable {
		let dateAdded: Date
		
		var isFavorite: Bool
		var numberOfDueCards: Int
		var sections: [String: Int]
		var rating: Int?
		
		#if DEBUG
		init(
			dateAdded: Date = .now,
			isFavorite: Bool = false,
			numberOfDueCards: Int = 0,
			sections: [String: Int] = [:],
			rating: Int? = nil
		) {
			self.dateAdded = dateAdded
			self.isFavorite = isFavorite
			self.numberOfDueCards = numberOfDueCards
			self.sections = sections
			self.rating = rating
		}
		#endif
		
		init(snapshot: DocumentSnapshot) {
			dateAdded = snapshot.getDate("added") ?? .now
			isFavorite = snapshot.get("favorite") as? Bool ?? false
			numberOfDueCards = snapshot.get("dueCardCount") as? Int ?? 0
			sections = snapshot.get("sections") as? [String: Int] ?? [:]
			let newRating = snapshot.get("rating") as? Int
			rating = newRating == 0 ? nil : newRating
		}
		
		var isDue: Bool {
			numberOfDueCards > 0
		}
		
		func numberOfDueCardsForSection(withId sectionId: String) -> Int? {
			sections[sectionId]
		}
		
		func isSectionUnlocked(withId sectionId: String) -> Bool {
			sections[sectionId] != nil
		}
	}
}

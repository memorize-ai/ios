import Foundation
import FirebaseFirestore

extension Deck {
	struct UserData: Identifiable, Equatable, Hashable {
		let id: String
		let dateAdded: Date
		
		var isFavorite: Bool
		var numberOfDueCards: Int
		var numberOfUnsectionedDueCards: Int
		var sections: [String: Int]
		var numberOfUnlockedCards: Int
		var rating: Int?
		
		#if DEBUG
		init(
			id: String = "",
			dateAdded: Date = .now,
			isFavorite: Bool = false,
			numberOfDueCards: Int = 0,
			numberOfUnsectionedDueCards: Int = 0,
			sections: [String: Int] = [:],
			numberOfUnlockedCards: Int = 0,
			rating: Int? = nil
		) {
			self.id = id
			self.dateAdded = dateAdded
			self.isFavorite = isFavorite
			self.numberOfDueCards = numberOfDueCards
			self.numberOfUnsectionedDueCards = numberOfUnsectionedDueCards
			self.sections = sections
			self.numberOfUnlockedCards = numberOfUnlockedCards
			self.rating = rating
		}
		#endif
		
		init(snapshot: DocumentSnapshot) {
			id = snapshot.documentID
			dateAdded = snapshot.getDate("added") ?? .now
			isFavorite = snapshot.get("favorite") as? Bool ?? false
			numberOfDueCards = snapshot.get("dueCardCount") as? Int ?? 0
			numberOfUnsectionedDueCards = snapshot.get("unsectionedDueCardCount") as? Int ?? 0
			sections = snapshot.get("sections") as? [String: Int] ?? [:]
			numberOfUnlockedCards = snapshot.get("unlockedCardCount") as? Int ?? 0
			let newRating = snapshot.get("rating") as? Int
			rating = newRating == 0 ? nil : newRating
		}
		
		var isDue: Bool {
			numberOfDueCards > 0
		}
		
		func numberOfDueCardsForSection(withId sectionId: String) -> Int? {
			sectionId.isEmpty
				? numberOfUnsectionedDueCards
				: sections[sectionId]
		}
		
		func isSectionUnlocked(withId sectionId: String) -> Bool {
			sectionId.isEmpty || sections[sectionId] != nil
		}
		
		mutating func updateFromSnapshot(_ snapshot: DocumentSnapshot) {
			isFavorite = snapshot.get("favorite") as? Bool ?? false
			numberOfDueCards = snapshot.get("dueCardCount") as? Int ?? 0
			numberOfUnsectionedDueCards = snapshot.get("unsectionedDueCardCount") as? Int ?? 0
			sections = snapshot.get("sections") as? [String: Int] ?? [:]
			numberOfUnlockedCards = snapshot.get("unlockedCardCount") as? Int ?? 0
			let newRating = snapshot.get("rating") as? Int
			rating = newRating == 0 ? nil : newRating
		}
	}
}

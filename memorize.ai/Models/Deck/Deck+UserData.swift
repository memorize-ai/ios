import Foundation
import FirebaseFirestore

extension Deck {
	struct UserData: Hashable {
		let dateAdded: Date
		
		var isFavorite: Bool
		var numberOfDueCards: Int
		var unlockedSections: [String]
		
		#if DEBUG
		init(
			dateAdded: Date,
			isFavorite: Bool,
			numberOfDueCards: Int,
			unlockedSections: [String] = []
		) {
			self.dateAdded = dateAdded
			self.isFavorite = isFavorite
			self.numberOfDueCards = numberOfDueCards
			self.unlockedSections = unlockedSections
		}
		#endif
		
		init(snapshot: DocumentSnapshot) {
			dateAdded = snapshot.get("added") as? Date ?? .init()
			isFavorite = snapshot.get("favorite") as? Bool ?? false
			numberOfDueCards = snapshot.get("dueCardCount") as? Int ?? 0
			unlockedSections = snapshot.get("unlockedSections") as? [String] ?? []
		}
		
		var isDue: Bool {
			numberOfDueCards > 0
		}
	}
}

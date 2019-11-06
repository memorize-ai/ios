import Foundation
import FirebaseFirestore

extension Deck {
	struct UserData {
		let dateAdded: Date
		
		var isFavorite: Bool
		var numberOfDueCards: Int
		
		#if DEBUG
		init(dateAdded: Date, isFavorite: Bool, numberOfDueCards: Int) {
			self.dateAdded = dateAdded
			self.isFavorite = isFavorite
			self.numberOfDueCards = numberOfDueCards
		}
		#endif
		
		init(snapshot: DocumentSnapshot) {
			self.dateAdded = snapshot.get("added") as? Date ?? .init()
			self.isFavorite = snapshot.get("favorite") as? Bool ?? false
			self.numberOfDueCards = snapshot.get("dueCardCount") as? Int ?? 0
		}
		
		var isDue: Bool {
			numberOfDueCards > 0
		}
	}
}

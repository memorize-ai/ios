import Foundation
import FirebaseFirestore

extension Deck {
	struct UserData {
		let dateAdded: Date
		
		var isFavorite: Bool
		var numberOfDueCards: Int
		
		var isDue: Bool {
			numberOfDueCards > 0
		}
		
		init(snapshot: DocumentSnapshot) {
			self.dateAdded = snapshot.get("added") as? Date ?? .init()
			self.isFavorite = snapshot.get("favorite") as? Bool ?? false
			self.numberOfDueCards = snapshot.get("dueCardCount") as? Int ?? 0
		}
	}
}

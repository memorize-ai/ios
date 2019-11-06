import Foundation

extension Deck {
	struct UserData {
		let dateAdded: Date
		
		var isFavorite: Bool
		var numberOfDueCards: Int
		
		var isDue: Bool {
			numberOfDueCards > 0
		}
	}
}

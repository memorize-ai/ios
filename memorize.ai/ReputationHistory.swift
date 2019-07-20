import Foundation
import Firebase

var reputationHistory = [GroupedReputationHistoryArray]()

class GroupedReputationHistoryArray {
	let date: Date
	var items: [ReputationHistoryItem]
	
	init(date: Date, items: [ReputationHistoryItem]) {
		self.date = date
		self.items = items
	}
}

class ReputationHistoryItem {
	let id: String
	let date: Date
	let amount: Int
	let description: String
	let after: Int
	let uid: String?
	let deckId: String?
	
	init(id: String, date: Date, amount: Int, description: String, after: Int, uid: String?, deckId: String?) {
		self.id = id
		self.date = date
		self.description = description
		self.after = after
		self.uid = uid
		self.deckId = deckId
	}
	
	convenience init(_ snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			date: snapshot.getDate("date") ?? Date(),
			amount: snapshot.get("amount") as? Int ?? 0,
			description: snapshot.get("description") as? String ?? "Error",
			after: snapshot.get("after") as? Int ?? 0,
			uid: snapshot.get("uid") as? String,
			deckId: snapshot.get("deckId") as? String
		)
	}
	
	@discardableResult
	func addToReputationHistory() -> ReputationHistoryItem {
		let current = Calendar.current
		if let groupedArray = (reputationHistory.first { current.isDate(self.date, inSameDayAs: $0.date) }) {
			groupedArray.items.append(self)
		} else {
			reputationHistory.append(GroupedReputationHistoryArray(date: date, items: [self]))
		}
		reputationHistory.sort { $0.date > $1.date }
		return self
	}
}

import Foundation
import FirebaseFirestore

extension Card {
	struct UserData: Hashable {
		var isNew: Bool
		var dueDate: Date
		
		#if DEBUG
		init(isNew: Bool, dueDate: Date) {
			self.isNew = isNew
			self.dueDate = dueDate
		}
		#endif
		
		init(snapshot: DocumentSnapshot) {
			isNew = snapshot.get("new") as? Bool ?? true
			dueDate = snapshot.getDate("due") ?? .now
		}
		
		mutating func updateFromSnapshot(_ snapshot: DocumentSnapshot) {
			isNew = snapshot.get("new") as? Bool ?? true
			dueDate = snapshot.getDate("due") ?? .now
		}
	}
}

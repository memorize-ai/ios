import Foundation
import FirebaseFirestore

extension Card {
	struct UserData: Hashable {
		var isNew: Bool
		var sectionId: String
		var dueDate: Date
		
		#if DEBUG
		init(
			isNew: Bool = true,
			sectionId: String = "",
			dueDate: Date = .now
		) {
			self.isNew = isNew
			self.sectionId = sectionId
			self.dueDate = dueDate
		}
		#endif
		
		init(snapshot: DocumentSnapshot) {
			isNew = snapshot.get("new") as? Bool ?? true
			sectionId = snapshot.get("section") as? String ?? ""
			dueDate = snapshot.getDate("due") ?? .now
		}
		
		mutating func updateFromSnapshot(_ snapshot: DocumentSnapshot) {
			isNew = snapshot.get("new") as? Bool ?? true
			sectionId = snapshot.get("section") as? String ?? ""
			dueDate = snapshot.getDate("due") ?? .now
		}
	}
}

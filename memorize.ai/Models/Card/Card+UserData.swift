import Foundation
import FirebaseFirestore

extension Card {
	struct UserData: Identifiable, Equatable, Hashable {
		let id: String
		
		var isNew: Bool
		var sectionId: String
		var dueDate: Date
		var streak: Int
		
		#if DEBUG
		init(
			id: String = "",
			isNew: Bool = true,
			sectionId: String = "",
			dueDate: Date = .now,
			streak: Int = 0
		) {
			self.id = id
			self.isNew = isNew
			self.sectionId = sectionId
			self.dueDate = dueDate
			self.streak = streak
		}
		#endif
		
		init(snapshot: DocumentSnapshot) {
			id = snapshot.documentID
			isNew = snapshot.get("new") as? Bool ?? true
			sectionId = snapshot.get("section") as? String ?? ""
			dueDate = snapshot.getDate("due") ?? .now
			streak = snapshot.get("streak") as? Int ?? 0
		}
		
		mutating func updateFromSnapshot(_ snapshot: DocumentSnapshot) {
			isNew = snapshot.get("new") as? Bool ?? true
			sectionId = snapshot.get("section") as? String ?? ""
			dueDate = snapshot.getDate("due") ?? .now
			streak = snapshot.get("streak") as? Int ?? 0
		}
	}
}

import Foundation
import FirebaseFirestore

extension Card {
	struct UserData: Hashable {
		var dueDate: Date
		
		#if DEBUG
		init(dueDate: Date) {
			self.dueDate = dueDate
		}
		#endif
		
		init(snapshot: DocumentSnapshot) {
			dueDate = snapshot.getDate("due") ?? .now
		}
	}
}

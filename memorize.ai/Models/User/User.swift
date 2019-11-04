import Combine
import FirebaseFirestore
import PromiseKit

final class User: ObservableObject, Identifiable, Equatable, Hashable {
	let id: String
	
	@Published var name: String
	@Published var email: String
	@Published var interests: [String]
	
	init(
		id: String,
		name: String,
		email: String,
		interests: [String]
	) {
		self.id = id
		self.name = name
		self.email = email
		self.interests = interests
	}
	
	convenience init(snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			name: snapshot.get("name") as? String ?? "Unknown",
			email: snapshot.get("email") as? String ?? "Unknown",
			interests: snapshot.get("topics") as? [String] ?? []
		)
	}
	
	@discardableResult
	func addInterest(topicId: String) -> Promise<Void> {
		firestore.document("users/\(id)").updateData([
			"topics": FieldValue.arrayUnion([topicId])
		]).done {
			self.interests.append(topicId)
		}
	}
	
	@discardableResult
	func removeInterest(topicId: String) -> Promise<Void> {
		firestore.document("users/\(id)").updateData([
			"topics": FieldValue.arrayRemove([topicId])
		]).done {
			self.interests.removeAll { $0 == topicId }
		}
	}
	
	static func == (lhs: User, rhs: User) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

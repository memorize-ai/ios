import Combine
import FirebaseFirestore

final class Card: ObservableObject, Identifiable, Equatable, Hashable {
	let id: String
	
	@Published var sectionId: String?
	@Published var front: String
	@Published var back: String
	@Published var numberOfViews: Int
	@Published var numberOfSkips: Int
	
	@Published var userData: UserData?
	
	init(
		id: String,
		sectionId: String?,
		front: String,
		back: String,
		numberOfViews: Int,
		numberOfSkips: Int,
		userData: UserData? = nil
	) {
		self.id = id
		self.sectionId = sectionId
		self.front = front
		self.back = back
		self.numberOfViews = numberOfViews
		self.numberOfSkips = numberOfSkips
		self.userData = userData
	}
	
	convenience init(snapshot: DocumentSnapshot) {
		let sectionId = snapshot.get("section") as? String ?? ""
		self.init(
			id: snapshot.documentID,
			sectionId: sectionId.isEmpty ? nil : sectionId,
			front: snapshot.get("front") as? String ?? "(empty)",
			back: snapshot.get("back") as? String ?? "(empty)",
			numberOfViews: snapshot.get("viewCount") as? Int ?? 0,
			numberOfSkips: snapshot.get("skipCount") as? Int ?? 0
		)
	}
	
	@discardableResult
	func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		let sectionId = snapshot.get("section") as? String
		self.sectionId = sectionId?.isEmpty ?? true ? nil : sectionId
		front = snapshot.get("front") as? String ?? front
		back = snapshot.get("back") as? String ?? back
		numberOfViews = snapshot.get("viewCount") as? Int ?? 0
		numberOfSkips = snapshot.get("skipCount") as? Int ?? 0
		return self
	}
	
	@discardableResult
	func updateUserDataFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		if userData == nil {
			userData = .init(snapshot: snapshot)
		} else {
			userData?.dueDate = snapshot.getDate("due") ?? .init()
		}
		return self
	}
	
	static func == (lhs: Card, rhs: Card) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

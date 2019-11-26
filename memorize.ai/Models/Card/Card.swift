import Combine
import FirebaseFirestore
import LoadingState

final class Card: ObservableObject, Identifiable, Equatable, Hashable {
	let id: String
	
	@Published var sectionId: String?
	@Published var front: String
	@Published var back: String
	@Published var numberOfViews: Int
	@Published var numberOfSkips: Int
	
	@Published var userData: UserData?
	@Published var userDataLoadingState = LoadingState()
	
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
	
	@discardableResult
	func loadUserData(forUser user: User, deck: Deck) -> Self {
		guard userDataLoadingState.isNone else { return self }
		userDataLoadingState.startLoading()
		user
			.documentReference
			.collection("decks/\(deck.id)/cards")
			.document(id)
			.addSnapshotListener { snapshot, error in
				guard
					error == nil,
					let snapshot = snapshot
				else {
					self.userDataLoadingState.fail(error: error ?? UNKNOWN_ERROR)
					return
				}
				self.updateUserDataFromSnapshot(snapshot)
				self.userDataLoadingState.succeed()
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

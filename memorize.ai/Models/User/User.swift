import Combine
import FirebaseAuth
import FirebaseFirestore
import PromiseKit

final class User: ObservableObject, Identifiable, Equatable, Hashable {
	let id: String
	
	@Published var name: String
	@Published var email: String
	@Published var interests: [String]
	@Published var numberOfDecks: Int
	@Published var decks: [Deck]
	
	init(
		id: String,
		name: String,
		email: String,
		interests: [String],
		numberOfDecks: Int,
		decks: [Deck] = []
	) {
		self.id = id
		self.name = name
		self.email = email
		self.interests = interests
		self.numberOfDecks = numberOfDecks
		self.decks = decks
	}
	
	convenience init(snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			name: snapshot.get("name") as? String ?? "Unknown",
			email: snapshot.get("email") as? String ?? "Unknown",
			interests: snapshot.get("topics") as? [String] ?? [],
			numberOfDecks: snapshot.get("deckCount") as? Int ?? 0
		)
	}
	
	convenience init(authUser user: FirebaseAuth.User) {
		self.init(
			id: user.uid,
			name: user.displayName ?? "Unknown",
			email: user.email ?? "Unknown",
			interests: [],
			numberOfDecks: 0
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
	
	func hasDeckWithId(_ deckId: String) -> Bool {
		decks.contains { $0.id == deckId }
	}
	
	func hasDeck(_ deck: Deck) -> Bool {
		decks.contains(deck)
	}
	
	static func == (lhs: User, rhs: User) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

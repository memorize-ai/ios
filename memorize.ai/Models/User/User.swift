import Combine
import FirebaseAuth
import FirebaseFirestore
import PromiseKit
import LoadingState

final class User: ObservableObject, Identifiable, Equatable, Hashable {
	let id: String
	
	@Published var name: String
	@Published var email: String
	@Published var interests: [String]
	@Published var numberOfDecks: Int
	@Published var xp: Int
	@Published var decks: [Deck]
	
	@Published var decksLoadingState = LoadingState()
	
	init(
		id: String,
		name: String,
		email: String,
		interests: [String],
		numberOfDecks: Int,
		xp: Int,
		decks: [Deck] = []
	) {
		self.id = id
		self.name = name
		self.email = email
		self.interests = interests
		self.numberOfDecks = numberOfDecks
		self.xp = xp
		self.decks = decks
	}
	
	convenience init(snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			name: snapshot.get("name") as? String ?? "Unknown",
			email: snapshot.get("email") as? String ?? "Unknown",
			interests: snapshot.get("topics") as? [String] ?? [],
			numberOfDecks: snapshot.get("deckCount") as? Int ?? 0,
			xp: snapshot.get("xp") as? Int ?? 0
		)
	}
	
	convenience init(authUser user: FirebaseAuth.User) {
		self.init(
			id: user.uid,
			name: user.displayName ?? "Unknown",
			email: user.email ?? "Unknown",
			interests: [],
			numberOfDecks: 0,
			xp: 0
		)
	}
	
	var dueDecks: [Deck] {
		decks.filter { $0.userData?.isDue ?? false }
	}
	
	var favoriteDecks: [Deck] {
		decks.filter { $0.userData?.isFavorite ?? false }
	}
	
	var numberOfDueCards: Int {
		decks.reduce(0) { acc, deck in
			acc + (deck.userData?.numberOfDueCards ?? 0)
		}
	}
	
	static func xpNeededForLevel(_ level: Int) -> Int {
		switch level {
		case 0:
			return 0
		case 1:
			return 1
		case 2:
			return 5
		case 3:
			return 10
		case 4:
			return 50
		default:
			return xpNeededForLevel(level - 1) + 25 * (level - 4)
		}
	}
	
	var level: Int {
		for level in 1... {
			if xp < Self.xpNeededForLevel(level) {
				return level - 1
			}
		}
		return -1
	}
	
	@discardableResult
	func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		name = snapshot.get("name") as? String ?? name
		email = snapshot.get("email") as? String ?? email
		interests = snapshot.get("topics") as? [String] ?? interests
		numberOfDecks = snapshot.get("deckCount") as? Int ?? numberOfDecks
		xp = snapshot.get("xp") as? Int ?? xp
		return self
	}
	
	@discardableResult
	func loadDecks(loadImages: Bool = true) -> Self {
		guard decksLoadingState.isNone else { return self }
		var isInitialIteration = true
		decksLoadingState.startLoading()
		firestore.collection("users/\(id)/decks").addSnapshotListener { snapshot, error in
			guard error == nil, let documentChanges = snapshot?.documentChanges else {
				self.decksLoadingState.fail(error: error ?? UNKNOWN_ERROR)
				return
			}
			if isInitialIteration {
				isInitialIteration = false
				self.decks.removeAll()
			}
			for change in documentChanges {
				let userDataSnapshot = change.document
				let deckId = userDataSnapshot.documentID
				switch change.type {
				case .added:
					Deck.fromId(deckId).done { deck in
						deck.updateUserDataFromSnapshot(userDataSnapshot)
						self.decks.append(loadImages ? deck.loadImage() : deck)
					}.catch { error in
						self.decksLoadingState.fail(error: error)
					}
				case .modified:
					self.deckWithId(deckId)?
						.updateUserDataFromSnapshot(userDataSnapshot)
				case .removed:
					self.decks.removeAll { $0.id == deckId }
				}
			}
			self.decksLoadingState.succeed()
		}
		return self
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
	
	func deckWithId(_ deckId: String) -> Deck? {
		decks.first { $0.id == deckId }
	}
	
	func recommendedDecks() -> Promise<[Deck]> {
		Deck.recommendedDecks(forUser: self)
	}
	
	static func == (lhs: User, rhs: User) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

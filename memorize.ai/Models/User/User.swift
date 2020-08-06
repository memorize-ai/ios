import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PromiseKit
import LoadingState

final class User: ObservableObject, Identifiable, Equatable, Hashable {
	static let MAX_CREATED_DECKS = 20
	
	enum DecksChangeEvent {
		case added(deck: Deck)
		case removed(id: String)
	}
	
	let id: String
	
	@Published var name: String
	@Published var email: String
	@Published var interests: [String]
	@Published var numberOfDecks: Int
	@Published var xp: Int
	@Published var allDecks: [String]
	@Published var decks: [Deck]
	@Published var createdDecks: [Deck]
	
	@Published var decksLoadingState = LoadingState()
	@Published var createdDecksLoadingState = LoadingState()
	
	var onDecksChange: (([Deck], DecksChangeEvent) -> Void)?
	
	init(
		id: String,
		name: String,
		email: String,
		interests: [String],
		numberOfDecks: Int,
		xp: Int,
		allDecks: [String] = [],
		decks: [Deck] = [],
		createdDecks: [Deck] = [],
		onDecksChange: (([Deck], DecksChangeEvent) -> Void)? = nil
	) {
		self.id = id
		self.name = name
		self.email = email
		self.interests = interests
		self.numberOfDecks = numberOfDecks
		self.xp = xp
		self.allDecks = allDecks
		self.decks = decks
		self.createdDecks = createdDecks
		self.onDecksChange = onDecksChange
	}
	
	convenience init(snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			name: snapshot.get("name") as? String ?? "",
			email: snapshot.get("email") as? String ?? "Unknown",
			interests: snapshot.get("topics") as? [String] ?? [],
			numberOfDecks: snapshot.get("deckCount") as? Int ?? 0,
			xp: snapshot.get("xp") as? Int ?? 0,
			allDecks: snapshot.get("allDecks") as? [String] ?? []
		)
	}
	
	convenience init(authUser user: FirebaseAuth.User) {
		self.init(
			id: user.uid,
			name: user.displayName ?? "",
			email: user.email ?? "Unknown",
			interests: [],
			numberOfDecks: 0,
			xp: 0
		)
	}
	
	var documentReference: DocumentReference {
		firestore.document("users/\(id)")
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
	
	static func levelForXP(_ xp: Int) -> Int {
		for level in 1... {
			if xp < xpNeededForLevel(level) {
				return level - 1
			}
		}
		return -1
	}
	
	var level: Int {
		Self.levelForXP(xp)
	}
	
	@discardableResult
	func setOnDecksChange(to handler: (([Deck], DecksChangeEvent) -> Void)?) -> Self {
		onDecksChange = handler
		return self
	}
	
	@discardableResult
	func setName(to name: String) -> Self {
		documentReference.updateData(["name": name]) as Void
		
		if let user = auth.currentUser {
			changeUserName(user: user, name: name)
		}
		
		return self
	}
	
	@discardableResult
	func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		name = snapshot.get("name") as? String ?? name
		email = snapshot.get("email") as? String ?? email
		interests = snapshot.get("topics") as? [String] ?? interests
		numberOfDecks = snapshot.get("deckCount") as? Int ?? numberOfDecks
		xp = snapshot.get("xp") as? Int ?? xp
		allDecks = snapshot.get("allDecks") as? [String] ?? allDecks
		return self
	}
	
	@discardableResult
	func loadDecks(loadImages: Bool = true) -> Self {
		guard decksLoadingState.isNone else { return self }
		var isInitialIteration = true
		decksLoadingState.startLoading()
		onBackgroundThread {
			self.documentReference.collection("decks").addSnapshotListener { snapshot, error in
				guard error == nil, let documentChanges = snapshot?.documentChanges else {
					onMainThread {
						self.decksLoadingState.fail(error: error ?? UNKNOWN_ERROR)
					}
					return
				}
				if isInitialIteration {
					isInitialIteration = false
					onMainThread {
						self.decks.removeAll()
					}
				}
				for change in documentChanges {
					let userDataSnapshot = change.document
					let deckId = userDataSnapshot.documentID
					switch change.type {
					case .added:
						Deck.fromId(deckId).done { deck in
							onMainThread {
								deck.updateUserDataFromSnapshot(userDataSnapshot)
								self.decks.append(loadImages ? deck.loadImage() : deck)
								self.onDecksChange?(self.decks, .added(deck: deck))
							}
						}.catch { error in
							onMainThread {
								self.decksLoadingState.fail(error: error)
							}
						}
					case .modified:
						onMainThread {
							self.deckWithId(deckId)?
								.updateUserDataFromSnapshot(userDataSnapshot)
						}
					case .removed:
						onMainThread {
							self.decks.removeAll { $0.id == deckId }
							self.onDecksChange?(self.decks, .removed(id: deckId))
						}
					}
				}
				onMainThread {
					self.decksLoadingState.succeed()
				}
			}
		}
		return self
	}
	
	@discardableResult
	func loadCreatedDecks(loadImages: Bool = true) -> Self {
		guard createdDecksLoadingState.isNone else { return self }
		createdDecksLoadingState.startLoading()
		onBackgroundThread {
			firestore
				.collection("decks")
				.whereField("creator", isEqualTo: self.id)
				.limit(to: Self.MAX_CREATED_DECKS)
				.addSnapshotListener { snapshot, error in
					guard error == nil, let documentChanges = snapshot?.documentChanges else {
						onMainThread {
							self.decksLoadingState.fail(error: error ?? UNKNOWN_ERROR)
						}
						return
					}
					
					for change in documentChanges {
						let publicDataSnapshot = change.document
						let deckId = publicDataSnapshot.documentID
						
						switch change.type {
						case .added:
							let deck = Deck(snapshot: publicDataSnapshot, snapshotListener: nil)
							var isInitialIteration = true
							
							self.documentReference
								.collection("decks")
								.document(deckId)
								.addSnapshotListener { userDataSnapshot, error in
									guard error == nil, let userDataSnapshot = userDataSnapshot else { return }
									
									onMainThread {
										deck.updateUserDataFromSnapshot(userDataSnapshot)
									}
									
									if isInitialIteration {
										isInitialIteration = false
										onMainThread {
											self.createdDecks.append(loadImages ? deck.loadImage() : deck)
										}
									}
								}
						case .modified:
							onMainThread {
								self.createdDecks.first { $0.id == deckId }?
									.updatePublicDataFromSnapshot(publicDataSnapshot)
							}
						case .removed:
							onMainThread {
								self.createdDecks.removeAll { $0.id == deckId }
							}
						}
					}
					
					onMainThread {
						self.decksLoadingState.succeed()
					}
				}
		}
		return self
	}
	
	@discardableResult
	func addInterest(topicId: String) -> Self {
		onBackgroundThread {
			self.documentReference
				.updateData([
					"topics": FieldValue.arrayUnion([topicId])
				])
				.done {
					onMainThread {
						self.interests.append(topicId)
					}
				}
				.cauterize()
		}
		return self
	}
	
	@discardableResult
	func removeInterest(topicId: String) -> Self {
		onBackgroundThread {
			self.documentReference
				.updateData([
					"topics": FieldValue.arrayRemove([topicId])
				])
				.done {
					onMainThread {
						self.interests.removeAll { $0 == topicId }
					}
				}
				.cauterize()
		}
		return self
	}
	
	@discardableResult
	func getEmptyDeck(withId deckId: String) -> Promise<Void> {
		documentReference.collection("decks").document(deckId).setData([
			"added": FieldValue.serverTimestamp()
		])
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

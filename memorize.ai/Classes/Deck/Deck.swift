import FirebaseFirestore

final class Deck: Identifiable, Equatable, Storable {
	let id: String
	let prepareForUpdate: (() -> Void)?
	let cardStore: CardStore
	var name: String? {
		willSet {
			prepareForUpdate?()
		}
	}
	
	init(id: String, prepareForUpdate: (() -> Void)? = nil, cardStore: CardStore = .init(), name: String? = nil) {
		self.id = id
		self.prepareForUpdate = prepareForUpdate
		self.cardStore = cardStore
		self.name = name
	}
	
	var publicPath: String {
		"decks/\(id)"
	}
	
	var publicDocument: DocumentReference {
		firestore.document(publicPath)
	}
	
	@discardableResult
	func updatePublicData(document: DocumentSnapshot) -> Self {
		name = document.get("name") as? String ?? name
		return self
	}
	
	@discardableResult
	func updateUserData(document: DocumentSnapshot) -> Self {
		// TODO: Update user data
		return self
	}
	
	static func == (lhs: Deck, rhs: Deck) -> Bool {
		lhs.id == rhs.id
	}
}

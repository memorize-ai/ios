import Combine
import FirebaseFirestore

final class DeckStore: ObservableObject {
	@Published var decks: [Deck]
	@Published var loadingState = LoadingState.default
	
	init(_ decks: [Deck] = []) {
		self.decks = decks
	}
	
	@discardableResult
	func observeAll(user: User) -> Self {
		loadingState = .loading()
		firestore.collection("users/\(user.id)/decks").addSnapshotListener().done { snapshot in
			snapshot.documentChanges.forEach { documentChange in
				let userDocument = documentChange.document
				let deckId = userDocument.documentID
				switch documentChange.type {
				case .added:
					self.handleDeckAdded(id: deckId)
				case .modified:
					self.handleDeckModified(id: deckId, userDocument: userDocument)
				case .removed:
					self.decks = self.decks.filter { $0.id != deckId }
				@unknown default:
					return
				}
			}
			self.loadingState = .success()
		}.catch { error in
			self.loadingState = .failure(message: error.localizedDescription)
		}
		return self
	}
	
	private func handleDeckAdded(id: String) {
		let deck = Deck(id: id, prepareForUpdate: objectWillChange.send)
		decks.append(deck)
		deck.publicDocument.addSnapshotListener().done { publicDeckSnapshot in
			deck.updatePublicData(document: publicDeckSnapshot)
		}.catch { error in
			self.loadingState = .failure(message: error.localizedDescription)
		}
	}
	
	private func handleDeckModified(id: String, userDocument: DocumentSnapshot) {
		guard let deck = get(id: id) else { return }
		deck.updateUserData(document: userDocument)
	}
	
	func get(id: String) -> Deck? {
		decks.first { $0.id == id }
	}
}

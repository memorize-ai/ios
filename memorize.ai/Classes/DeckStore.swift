import Combine

final class DeckStore: ObservableObject {
	@Published var decks: [Deck]
	@Published var loadingState: LoadingState
	
	init(_ decks: [Deck] = [], loadingState: LoadingState = .default) {
		self.decks = decks
		self.loadingState = loadingState
	}
	
	@discardableResult
	func observeAll(user: User) -> Self {
		loadingState = .loading()
		firestore.collection("users/\(user.id)/decks").addSnapshotListener().done { snapshot in
			snapshot.documentChanges.forEach { documentChange in
				let document = documentChange.document
				let deckId = document.documentID
				switch documentChange.type {
				case .added:
					let deck = Deck(id: deckId)
					deck.publicDocument.addSnapshotListener().done { publicDeckSnapshot in
						deck.updatePublicData(document: publicDeckSnapshot)
					}.catch { error in
						self.loadingState = .failure(message: error.localizedDescription)
					}
					self.decks.append(deck)
				case .modified:
					self.get(id: deckId)?.updateUserData(document: document)
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
	
	func get(id: String) -> Deck? {
		decks.first { $0.id == id }
	}
}

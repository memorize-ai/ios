import Combine
import FirebaseFirestore
import PromiseKit
import LoadingState

extension Deck {
	final class Section: ObservableObject, Identifiable, Equatable, Hashable {
		let id: String
		let parent: Deck
		
		@Published var name: String
		@Published var numberOfCards: Int
		
		@Published var cards: [Card]
		@Published var cardsLoadingState = LoadingState()
		
		init(
			id: String,
			parent: Deck,
			name: String,
			numberOfCards: Int,
			cards: [Card] = []
		) {
			self.id = id
			self.parent = parent
			self.name = name
			self.numberOfCards = numberOfCards
			self.cards = cards
		}
		
		convenience init(parent: Deck, snapshot: DocumentSnapshot) {
			self.init(
				id: snapshot.documentID,
				parent: parent,
				name: snapshot.get("name") as? String ?? "Unknown",
				numberOfCards: snapshot.get("cardCount") as? Int ?? 0
			)
		}
		
		@discardableResult
		func loadCards(withUserData loadWithUserData: Bool = false) -> Self {
			guard cardsLoadingState.isNone else { return self }
			cardsLoadingState.startLoading()
			parent
				.documentReference
				.collection("cards")
				.whereField("section", isEqualTo: id)
				.addSnapshotListener { snapshot, error in
					guard error == nil, let documentChanges = 
				}
			return self
		}
		
		@discardableResult
		func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
			name = snapshot.get("name") as? String ?? name
			numberOfCards = snapshot.get("cardCount") as? Int ?? 0
			return self
		}
		
		static func == (lhs: Section, rhs: Section) -> Bool {
			lhs.id == rhs.id
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}
}

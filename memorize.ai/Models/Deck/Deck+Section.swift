import Combine
import FirebaseFirestore
import PromiseKit
import LoadingState

extension Deck {
	final class Section: ObservableObject, Identifiable, Equatable, Hashable {
		let id: String
		
		@Published var name: String
		@Published var numberOfCards: Int
		
		@Published var cards: [Card]
		@Published var cardsLoadingState = LoadingState()
		
		init(id: String, name: String, numberOfCards: Int, cards: [Card] = []) {
			self.id = id
			self.name = name
			self.numberOfCards = numberOfCards
			self.cards = cards
		}
		
		convenience init(snapshot: DocumentSnapshot) {
			self.init(
				id: snapshot.documentID,
				name: snapshot.get("name") as? String ?? "Unknown",
				numberOfCards: snapshot.get("cardCount") as? Int ?? 0
			)
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

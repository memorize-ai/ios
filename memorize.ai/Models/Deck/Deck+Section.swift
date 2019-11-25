import Combine
import FirebaseFirestore
import PromiseKit

extension Deck {
	final class Section: ObservableObject, Identifiable, Equatable, Hashable {
		let id: String
		
		@Published var name: String
		@Published var numberOfCards: Int
		
		init(id: String, name: String, numberOfCards: Int) {
			self.id = id
			self.name = name
			self.numberOfCards = numberOfCards
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

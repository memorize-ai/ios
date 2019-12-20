import Foundation
import Combine
import FirebaseFirestore
import PromiseKit
import LoadingState

extension Card {
	final class Draft: ObservableObject, Identifiable, Equatable, Hashable {
		let id: String
		let parent: Deck
		
		@Published var section: Deck.Section?
		@Published var front: String
		@Published var back: String
		
		@Published var publishLoadingState = LoadingState()
		
		init(
			id: String = UUID().uuidString,
			parent: Deck,
			section: Deck.Section? = nil,
			front: String = "",
			back: String = ""
		) {
			self.id = id
			self.parent = parent
			self.section = section
			self.front = front
			self.back = back
		}
		
		convenience init(parent: Deck, card: Card, section: Deck.Section?) {
			self.init(
				id: card.id,
				parent: parent,
				section: section,
				front: card.front,
				back: card.back
			)
		}
		
		var cards: CollectionReference {
			parent.documentReference.collection("cards")
		}
		
		var isPublishable: Bool {
			!(front.isEmpty || back.isEmpty)
		}
		
		@discardableResult
		func publishAsUpdate() -> Promise<Void> {
			cards.document(id).updateData([
				"section": section?.id ?? "",
				"front": front,
				"back": back
			])
		}
		
		@discardableResult
		func publishAsNew() -> Promise<DocumentReference> {
			cards.addDocument(data: [
				"section": section?.id ?? "",
				"front": front,
				"back": back,
				"viewCount": 0,
				"skipCount": 0
			])
		}
		
		static func == (lhs: Draft, rhs: Draft) -> Bool {
			lhs.id == rhs.id
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}
}

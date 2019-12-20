import Foundation
import Combine
import FirebaseFirestore
import PromiseKit
import LoadingState

extension Card {
	final class Draft: ObservableObject, Identifiable, Equatable, Hashable {
		let id: String
		let parent: Deck
		
		@Published var section: Deck.Section? { didSet { onChange?() } }
		@Published var front: String { didSet { onChange?() } }
		@Published var back: String { didSet { onChange?() } }
		
		@Published var publishLoadingState = LoadingState()
		
		var onChange: (() -> Void)?
		
		init(
			id: String = UUID().uuidString,
			parent: Deck,
			section: Deck.Section? = nil,
			front: String = "",
			back: String = "",
			onChange: (() -> Void)? = nil
		) {
			self.id = id
			self.parent = parent
			self.section = section
			self.front = front
			self.back = back
			self.onChange = onChange
		}
		
		convenience init(
			parent: Deck,
			card: Card,
			section: Deck.Section?,
			onChange: (() -> Void)? = nil
		) {
			self.init(
				id: card.id,
				parent: parent,
				section: section,
				front: card.front,
				back: card.back,
				onChange: onChange
			)
		}
		
		var cards: CollectionReference {
			parent.documentReference.collection("cards")
		}
		
		var title: String {
			Card.stripFormatting(front)
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

import Foundation
import Combine
import FirebaseFirestore
import PromiseKit
import LoadingState

extension Card {
	final class Draft: ObservableObject, Identifiable, Equatable, Hashable {
		let id: String
		let parent: Deck
		
		var sectionId: String?
		
		@Published var section: Deck.Section? {
			willSet {
				sectionId = newValue?.id
			}
			didSet {
				onChange?()
			}
		}
		@Published var front: String { didSet { onChange?() } }
		@Published var back: String { didSet { onChange?() } }
		
		@Published var publishLoadingState = LoadingState()
		
		var onChange: (() -> Void)?
		
		init(
			id: String = UUID().uuidString,
			parent: Deck,
			sectionId: String? = nil,
			front: String = "",
			back: String = "",
			onChange: (() -> Void)? = nil
		) {
			self.id = id
			self.parent = parent
			self.sectionId = sectionId
			section = parent.sections.first { $0.id == sectionId }
			self.front = front
			self.back = back
			self.onChange = onChange
		}
		
		convenience init(
			parent: Deck,
			card: Card,
			onChange: (() -> Void)? = nil
		) {
			self.init(
				id: card.id,
				parent: parent,
				sectionId: card.sectionId,
				front: card.front,
				back: card.back,
				onChange: onChange
			)
		}
		
		convenience init(parent: Deck, snapshot: DocumentSnapshot) {
			self.init(
				id: snapshot.documentID,
				parent: parent,
				sectionId: snapshot.get("section") as? String,
				front: snapshot.get("front") as? String ?? "",
				back: snapshot.get("back") as? String ?? ""
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
		
		var isEmpty: Bool {
			sectionId == nil && front.isEmpty && back.isEmpty
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
		
		@discardableResult
		func updateDraft(forUser user: User) -> Promise<Void> {
			user.documentReference
				.collection("decks/\(parent.id)/drafts")
				.document(id)
				.updateData([
					"section": section?.id ?? FieldValue.delete(),
					"front": front,
					"back": back
				])
		}
		
		@discardableResult
		func removeDraft(forUser user: User) -> Promise<Void> {
			user.documentReference
				.collection("decks/\(parent.id)/drafts")
				.document(id)
				.delete()
		}
		
		static func == (lhs: Draft, rhs: Draft) -> Bool {
			lhs.id == rhs.id
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}
}
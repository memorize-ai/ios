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
				sectionId = newValue?.id.nilIfEmpty
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
			id: String = randomId,
			parent: Deck,
			sectionId: String? = nil,
			front: String = "",
			back: String = "",
			onChange: (() -> Void)? = nil
		) {
			self.id = id
			self.parent = parent
			self.sectionId = sectionId
			section = parent.section(withId: sectionId ?? "")
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
		func publishAsNew(forUser user: User) -> Promise<Void> {
			when(fulfilled: [
				cards.addDocument(data: [
					"section": section?.id ?? "",
					"front": front,
					"back": back,
					"viewCount": 0,
					"reviewCount": 0,
					"skipCount": 0
				]).asVoid()
			] + (
				section?.isUnlocked ?? true
					? [
						user.documentReference
							.collection("decks")
							.document(parent.id)
							.updateData([
								"dueCardCount": FieldValue.increment(1 as Int64),
								(section?.isUnsectioned ?? true
									? "unsectionedDueCardCount"
									: "sections.\(section?.id ?? "")"
								): FieldValue.increment(1 as Int64)
							]).asVoid()
					]
					: []
			))
		}
		
		@discardableResult
		func updateDraft(forUser user: User) -> Promise<Void> {
			var data = [
				"front": front,
				"back": back
			]
			if let sectionId = sectionId {
				data["section"] = sectionId
			}
			return user.documentReference
				.collection("decks/\(parent.id)/drafts")
				.document(id)
				.setData(data)
		}
		
		@discardableResult
		func removeDraft(forUser user: User) -> Promise<Void> {
			user.documentReference
				.collection("decks/\(parent.id)/drafts")
				.document(id)
				.delete()
		}
		
		@discardableResult
		func showDeleteAlert(
			forUser user: User,
			title: String = "Delete card",
			message: String? = "Are you sure? This action cannot be undone.",
			completion: (() -> Void)? = nil
		) -> Self {
			showAlert(title: title, message: message) { alert in
				alert.addAction(.init(title: "Cancel", style: .cancel))
				alert.addAction(.init(title: "Delete", style: .destructive) { _ in
					self.publishLoadingState.startLoading()
					onBackgroundThread {
						self.delete(forUser: user).done {
							onMainThread {
								self.publishLoadingState.succeed()
								completion?()
							}
						}.catch { error in
							onMainThread {
								self.publishLoadingState.fail(error: error)
							}
						}
					}
				})
			}
			return self
		}
		
		@discardableResult
		func delete(forUser user: User) -> Promise<Void> {
			when(fulfilled: [
				cards.document(id).delete()
			] + (
				parent.card(withId: id, sectionId: sectionId)?.isDue ?? false
					? [
						user.documentReference
							.collection("decks")
							.document(parent.id)
							.updateData([
								"dueCardCount": FieldValue.increment(-1 as Int64),
								(section?.isUnsectioned ?? true
									? "unsectionedDueCardCount"
									: "sections.\(section?.id ?? "")"
								): FieldValue.increment(-1 as Int64)
							]).asVoid()
					]
					: []
			))
		}
		
		static func == (lhs: Draft, rhs: Draft) -> Bool {
			lhs.id == rhs.id
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}
}

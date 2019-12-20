import Foundation
import Combine
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
		
		var isPublishable: Bool {
			!(front.isEmpty || back.isEmpty)
		}
		
		@discardableResult
		func publish(asNewCard isNew: Bool) -> Promise<Void> {
			let collection = parent.documentReference.collection("cards")
			return isNew
				? collection.addDocument(data: [
					"section": section?.id ?? "",
					
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

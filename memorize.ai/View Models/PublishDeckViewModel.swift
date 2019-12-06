import SwiftUI

final class PublishDeckViewModel: ObservableObject {
	let deck: Deck?
	
	@Published var image: Image?
	@Published var topics: [String]
	@Published var name: String
	@Published var subtitle: String
	@Published var description: String
	
	init(deck: Deck? = nil) {
		self.deck = deck
		image = deck?.image
		topics = deck?.topics ?? []
		name = deck?.name ?? ""
		subtitle = deck?.subtitle ?? ""
		description = deck?.description ?? ""
	}
	
	func publish() {
		// TODO: Publish deck
	}
	
	func isTopicSelected(_ topic: Topic) -> Bool {
		topics.contains(topic.id)
	}
	
	func toggleTopicSelect(_ topic: Topic) {
		let topicId = topic.id
		isTopicSelected(topic)
			? topics.removeAll { $0 == topicId }
			: topics.append(topicId)
	}
}

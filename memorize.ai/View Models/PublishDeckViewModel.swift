import SwiftUI
import FirebaseFirestore
import LoadingState

final class PublishDeckViewModel: ObservableObject {
	let deck: Deck?
	
	@Published var image: Image?
	@Published var topics: [String]
	@Published var name: String
	@Published var subtitle: String
	@Published var description: String
	
	@Published var publishLoadingState = LoadingState()
	
	init(deck: Deck? = nil) {
		self.deck = deck
		image = deck?.image
		topics = deck?.topics ?? []
		name = deck?.name ?? ""
		subtitle = deck?.subtitle ?? ""
		description = deck?.description ?? ""
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
	
	func publish(currentUser: User) { // TODO: Also upload/delete image
		publishLoadingState.startLoading()
		if let deck = deck {
			deck.documentReference.updateData([
				"topics": topics,
				"hasImage": image != nil,
				"name": name,
				"subtitle": subtitle,
				"description": description
			]).done {
				self.publishLoadingState.succeed()
			}.catch { error in
				self.publishLoadingState.fail(error: error)
			}
		} else {
			firestore.collection("decks").addDocument(data: [
				"topics": topics,
				"hasImage": image != nil,
				"name": name,
				"subtitle": subtitle,
				"description": description,
				"viewCount": 0,
				"uniqueViewCount": 0,
				"ratingCount": 0,
				"1StarRatingCount": 0,
				"2StarRatingCount": 0,
				"3StarRatingCount": 0,
				"4StarRatingCount": 0,
				"5StarRatingCount": 0,
				"averageRating": 0,
				"downloadCount": 0,
				"cardCount": 0,
				"currentUserCount": 0,
				"allTimeUserCount": 0,
				"favoriteCount": 0,
				"creator": currentUser.id,
				"created": FieldValue.serverTimestamp(),
				"updated": FieldValue.serverTimestamp()
			]).done { _ in
				self.publishLoadingState.succeed()
			}.catch { error in
				self.publishLoadingState.fail(error: error)
			}
		}
	}
}

import SwiftUI
import FirebaseFirestore
import PromiseKit
import LoadingState

final class PublishDeckViewModel: ViewModel {
	let deck: Deck?
	
	@Published var image: UIImage? {
		willSet {
			displayImage = newValue.map(Image.init)
		}
		didSet {
			didChangeImage = true
		}
	}
	@Published var topics: [String]
	@Published var name: String
	@Published var subtitle: String
	@Published var description: String
	
	@Published var publishLoadingState = LoadingState()
    
    @Published var isImagePopUpShowing = false
	@Published var isImagePickerShowing = false
	
	var displayImage: Image?
	var imagePickerSource: ImagePicker.Source!
	var didChangeImage = false
	
	init(deck: Deck? = nil) {
		self.deck = deck
		image = deck?.image
		topics = deck?.topics ?? []
		name = deck?.name ?? ""
		subtitle = deck?.subtitle ?? ""
		description = deck?.description ?? ""
	}
	
	var isPublishButtonDisabled: Bool {
		name.isEmpty
	}
	
	func showImagePicker(source: ImagePicker.Source) {
		imagePickerSource = source
		isImagePickerShowing = true
		isImagePopUpShowing = false
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
	
	func uploadDeckImage(deckId: String, data: Data?) -> Promise<Void> {
		guard let data = data else { return .init() }
		return storage
			.child("decks/\(deckId)")
			.putData(data, metadata: .jpeg)
	}
	
	func reset() {
		image = nil
		topics = []
		name = ""
		subtitle = ""
		description = ""
		publishLoadingState.reset()
		didChangeImage = false
	}
	
	func publish(currentUser: User, completion: @escaping () -> Void) {
		publishLoadingState.startLoading()
		if let deck = deck {
			when(fulfilled: [
				deck.documentReference.updateData([
					"topics": topics,
					"hasImage": image != nil,
					"name": name,
					"subtitle": subtitle,
					"description": description
				])
			] + (
				didChangeImage
					? [deck.setImage(image)]
					: []
			)).done {
				self.publishLoadingState.succeed()
				self.reset()
				completion()
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
				"unsectionedCardCount": 0,
				"currentUserCount": 0,
				"allTimeUserCount": 0,
				"favoriteCount": 0,
				"creator": currentUser.id,
				"created": FieldValue.serverTimestamp(),
				"updated": FieldValue.serverTimestamp()
			]).done { document in
				let deckId = document.documentID
				Deck.imageCache[deckId] = self.image
				when(fulfilled: [
					self.uploadDeckImage(
						deckId: deckId,
						data: self.image?.compressedData
					),
					currentUser.getEmptyDeck(withId: deckId)
				]).done {
					self.publishLoadingState.succeed()
					self.reset()
					completion()
				}.catch { error in
					self.publishLoadingState.fail(error: error)
				}
			}.catch { error in
				self.publishLoadingState.fail(error: error)
			}
		}
	}
}

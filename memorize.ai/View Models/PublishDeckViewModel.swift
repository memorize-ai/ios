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
	var imagePickerSource = ImagePicker.Source.photoLibrary
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
		
		popUpWithAnimation {
			isImagePopUpShowing = false
		}
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
	
	func publish(currentUser: User, completion: @escaping (String) -> Void) {
		publishLoadingState.startLoading()
		onBackgroundThread {
			if let deck = self.deck {
				when(fulfilled: [
					deck.documentReference.updateData([
						"topics": self.topics,
						"hasImage": self.image != nil,
						"name": self.name,
						"subtitle": self.subtitle,
						"description": self.description
					])
				] + (
					self.didChangeImage
						? [deck.setImage(self.image)]
						: []
				)).done {
					onMainThread {
						deck.image = self.image
						self.publishLoadingState.succeed()
						self.reset()
						completion(deck.id)
					}
				}.catch { error in
					onMainThread {
						self.publishLoadingState.fail(error: error)
					}
				}
			} else {
				let document = firestore.collection("decks").document()
				let deckId = document.documentID
				
				document.setData([
					"slug": Deck.createSlug(id: deckId, name: self.name),
					"topics": self.topics,
					"hasImage": self.image != nil,
					"name": self.name,
					"subtitle": self.subtitle,
					"description": self.description,
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
				]).done {
					Deck.imageCache[deckId] = self.image
					when(fulfilled: [
						self.uploadDeckImage(
							deckId: deckId,
							data: self.image?.compressedData
						),
						currentUser.getEmptyDeck(withId: deckId)
					]).done {
						onMainThread {
							self.publishLoadingState.succeed()
							self.reset()
							completion(deckId)
						}
					}.catch { error in
						onMainThread {
							self.publishLoadingState.fail(error: error)
						}
					}
				}.catch { error in
					onMainThread {
						self.publishLoadingState.fail(error: error)
					}
				}
			}
		}
	}
}

import SwiftUI
import FirebaseFirestore
import PromiseKit
import LoadingState

final class Deck: ObservableObject, Identifiable, Equatable, Hashable {
	static let maxNumberOfPreviewCards = 20
	
	static var cache = [String: Deck]()
	static var imageCache = [String: Image]()
	
	let id: String
	let creatorId: String
	let dateCreated: Date
	
	@Published var topics: [String]
	@Published var hasImage: Bool
	@Published var image: Image?
	@Published var name: String
	@Published var subtitle: String
	@Published var description: String
	@Published var numberOfViews: Int
	@Published var numberOfUniqueViews: Int
	@Published var numberOfRatings: Int
	@Published var numberOf1StarRatings: Int
	@Published var numberOf2StarRatings: Int
	@Published var numberOf3StarRatings: Int
	@Published var numberOf4StarRatings: Int
	@Published var numberOf5StarRatings: Int
	@Published var averageRating: Double
	@Published var numberOfDownloads: Int
	@Published var numberOfCards: Int
	@Published var numberOfCurrentUsers: Int
	@Published var numberOfAllTimeUsers: Int
	@Published var dateLastUpdated: Date
	
	@Published var userData: UserData?
	@Published var sections: [Section]
	@Published var creator: User?
	@Published var previewCards: [Card]
	
	@Published var imageLoadingState = LoadingState()
	@Published var userDataLoadingState = LoadingState()
	@Published var getLoadingState = LoadingState()
	@Published var sectionsLoadingState = LoadingState()
	@Published var creatorLoadingState = LoadingState()
	@Published var previewCardsLoadingState = LoadingState()
	@Published var topicsLoadingState = LoadingState()
	
	init(
		id: String,
		topics: [String],
		hasImage: Bool,
		image: Image? = nil,
		name: String,
		subtitle: String,
		description: String,
		numberOfViews: Int,
		numberOfUniqueViews: Int,
		numberOfRatings: Int,
		numberOf1StarRatings: Int,
		numberOf2StarRatings: Int,
		numberOf3StarRatings: Int,
		numberOf4StarRatings: Int,
		numberOf5StarRatings: Int,
		averageRating: Double,
		numberOfDownloads: Int,
		numberOfCards: Int,
		numberOfCurrentUsers: Int,
		numberOfAllTimeUsers: Int,
		creatorId: String,
		dateCreated: Date,
		dateLastUpdated: Date,
		userData: UserData? = nil,
		sections: [Section] = [],
		creator: User? = nil,
		previewCards: [Card] = []
	) {
		self.id = id
		self.topics = topics
		self.hasImage = hasImage
		self.image = image
		self.name = name
		self.subtitle = subtitle
		self.description = description
		self.numberOfViews = numberOfViews
		self.numberOfUniqueViews = numberOfUniqueViews
		self.numberOfRatings = numberOfRatings
		self.numberOf1StarRatings = numberOf1StarRatings
		self.numberOf2StarRatings = numberOf2StarRatings
		self.numberOf3StarRatings = numberOf3StarRatings
		self.numberOf4StarRatings = numberOf4StarRatings
		self.numberOf5StarRatings = numberOf5StarRatings
		self.averageRating = averageRating
		self.numberOfDownloads = numberOfDownloads
		self.numberOfCards = numberOfCards
		self.numberOfCurrentUsers = numberOfCurrentUsers
		self.numberOfAllTimeUsers = numberOfAllTimeUsers
		self.creatorId = creatorId
		self.dateCreated = dateCreated
		self.dateLastUpdated = dateLastUpdated
		self.userData = userData
		self.sections = sections
		self.creator = creator
		self.previewCards = previewCards
	}
	
	convenience init(snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			topics: snapshot.get("topics") as? [String] ?? [],
			hasImage: snapshot.get("hasImage") as? Bool ?? false,
			name: snapshot.get("name") as? String ?? "Unknown",
			subtitle: snapshot.get("subtitle") as? String ?? "(error)",
			description: snapshot.get("description") as? String ?? "(error)",
			numberOfViews: snapshot.get("viewCount") as? Int ?? 0,
			numberOfUniqueViews: snapshot.get("uniqueViewCount") as? Int ?? 0,
			numberOfRatings: snapshot.get("ratingCount") as? Int ?? 0,
			numberOf1StarRatings: snapshot.get("1StarRatingCount") as? Int ?? 0,
			numberOf2StarRatings: snapshot.get("2StarRatingCount") as? Int ?? 0,
			numberOf3StarRatings: snapshot.get("3StarRatingCount") as? Int ?? 0,
			numberOf4StarRatings: snapshot.get("4StarRatingCount") as? Int ?? 0,
			numberOf5StarRatings: snapshot.get("5StarRatingCount") as? Int ?? 0,
			averageRating: snapshot.get("averageRating") as? Double ?? 0,
			numberOfDownloads: snapshot.get("downloadCount") as? Int ?? 0,
			numberOfCards: snapshot.get("cardCount") as? Int ?? 0,
			numberOfCurrentUsers: snapshot.get("currentUserCount") as? Int ?? 0,
			numberOfAllTimeUsers: snapshot.get("allTimeUserCount") as? Int ?? 0,
			creatorId: snapshot.get("creator") as? String ?? "0",
			dateCreated: snapshot.getDate("created") ?? .now,
			dateLastUpdated: snapshot.getDate("updated") ?? .now
		)
	}
	
	#if DEBUG
	static func _new(
		id: String = "0",
		topics: [String] = [],
		hasImage: Bool = false,
		image: Image? = nil,
		name: String = "",
		subtitle: String = "",
		description: String = "",
		numberOfViews: Int = 0,
		numberOfUniqueViews: Int = 0,
		numberOfRatings: Int = 0,
		numberOf1StarRatings: Int = 0,
		numberOf2StarRatings: Int = 0,
		numberOf3StarRatings: Int = 0,
		numberOf4StarRatings: Int = 0,
		numberOf5StarRatings: Int = 0,
		averageRating: Double = 0,
		numberOfDownloads: Int = 0,
		numberOfCards: Int = 0,
		numberOfCurrentUsers: Int = 0,
		numberOfAllTimeUsers: Int = 0,
		creatorId: String = "0",
		dateCreated: Date = .now,
		dateLastUpdated: Date = .now,
		userData: UserData? = nil,
		sections: [Section] = [],
		creator: User? = nil,
		previewCards: [Card] = []
	) -> Self {
		.init(
			id: id,
			topics: topics,
			hasImage: hasImage,
			image: image,
			name: name,
			subtitle: subtitle,
			description: description,
			numberOfViews: numberOfViews,
			numberOfUniqueViews: numberOfUniqueViews,
			numberOfRatings: numberOfRatings,
			numberOf1StarRatings: numberOf1StarRatings,
			numberOf2StarRatings: numberOf2StarRatings,
			numberOf3StarRatings: numberOf3StarRatings,
			numberOf4StarRatings: numberOf4StarRatings,
			numberOf5StarRatings: numberOf5StarRatings,
			averageRating: averageRating,
			numberOfDownloads: numberOfDownloads,
			numberOfCards: numberOfCards,
			numberOfCurrentUsers: numberOfCurrentUsers,
			numberOfAllTimeUsers: numberOfAllTimeUsers,
			creatorId: creatorId,
			dateCreated: dateCreated,
			dateLastUpdated: dateLastUpdated,
			userData: userData,
			sections: sections,
			creator: creator,
			previewCards: previewCards
		)
	}
	#endif
	
	var documentReference: DocumentReference {
		firestore.document("decks/\(id)")
	}
	
	@discardableResult
	func loadImage() -> Self {
		guard imageLoadingState.isNone && hasImage else { return self }
		imageLoadingState.startLoading()
		if let cachedImage = Self.imageCache[id] {
			image = cachedImage
			imageLoadingState.succeed()
		} else {
			storage.child("decks/\(id)").getData().done { data in
				guard let image = Image(data: data) else {
					self.imageLoadingState.fail(message: "Malformed data")
					return
				}
				self.image = image
				Self.imageCache[self.id] = image
				self.imageLoadingState.succeed()
			}.catch { error in
				self.imageLoadingState.fail(error: error)
			}
		}
		return self
	}
	
	@discardableResult
	func loadUserData(user: User) -> Self {
		guard userDataLoadingState.isNone else { return self }
		userDataLoadingState.startLoading()
		firestore.document("users/\(user.id)/decks/\(id)").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot else {
				self.userDataLoadingState.fail(
					error: error ?? UNKNOWN_ERROR
				)
				return
			}
			self.updateUserDataFromSnapshot(snapshot)
			self.userDataLoadingState.succeed()
		}
		return self
	}
	
	@discardableResult
	func loadSections() -> Self {
		guard sectionsLoadingState.isNone else { return self }
		sectionsLoadingState.startLoading()
		documentReference.collection("sections").addSnapshotListener { snapshot, error in
			guard error == nil, let documentChanges = snapshot?.documentChanges else {
				self.sectionsLoadingState.fail(error: error ?? UNKNOWN_ERROR)
				return
			}
			for change in documentChanges {
				let document = change.document
				let sectionId = document.documentID
				switch change.type {
				case .added:
					self.sections.append(.init(parent: self, snapshot: document))
				case .modified:
					self.sections.first { $0.id == sectionId }?
						.updateFromSnapshot(document)
				case .removed:
					self.sections.removeAll { $0.id == sectionId }
				}
			}
			self.sectionsLoadingState.succeed()
		}
		return self
	}
	
	@discardableResult
	func loadCreator() -> Self {
		guard creatorLoadingState.isNone else { return self }
		creatorLoadingState.startLoading()
		firestore.document("users/\(creatorId)").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot else {
				self.creatorLoadingState.fail(error: error ?? UNKNOWN_ERROR)
				return
			}
			if let creator = self.creator {
				creator.updateFromSnapshot(snapshot)
			} else {
				self.creator = .init(snapshot: snapshot)
			}
			self.creatorLoadingState.succeed()
		}
		return self
	}
	
	@discardableResult
	func loadPreviewCards() -> Self {
		guard previewCardsLoadingState.isNone else { return self }
		previewCardsLoadingState.startLoading()
		documentReference
			.collection("cards")
			.order(by: "viewCount")
			.limit(to: Self.maxNumberOfPreviewCards)
			.addSnapshotListener { snapshot, error in
				guard error == nil, let documentChanges = snapshot?.documentChanges else {
					self.previewCardsLoadingState.fail(error: error ?? UNKNOWN_ERROR)
					return
				}
				for change in documentChanges {
					let document = change.document
					let cardId = document.documentID
					switch change.type {
					case .added:
						self.previewCards.append(.init(snapshot: document))
					case .modified:
						self.previewCards.first { $0.id == cardId }?
							.updateFromSnapshot(document)
						self.previewCards.sort(by: \.numberOfViews)
					case .removed:
						self.previewCards.removeAll { $0.id == cardId }
					}
				}
				self.previewCardsLoadingState.succeed()
			}
		return self
	}
	
	@discardableResult
	func loadTopics(
		in allTopics: [Topic],
		loadImages: Bool = true,
		completion: @escaping (Topic) -> Void
	) -> Self {
		guard topicsLoadingState.isNone else { return self }
		topicsLoadingState.startLoading()
		for topicId in topics where !(allTopics.contains { $0.id == topicId }) {
			Topic.fromId(topicId).done { topic in
				completion(loadImages ? topic.loadImage() : topic)
				self.topicsLoadingState.succeed()
			}.catch { error in
				self.topicsLoadingState.fail(error: error)
			}
		}
		return self
	}
	
	func topics(in allTopics: [Topic]) -> [Topic?] {
		topics.map { topicId in
			allTopics.first { $0.id == topicId }
		}
	}
	
	@discardableResult
	func get(user: User) -> Self {
		getLoadingState.startLoading()
		firestore.document("users/\(user.id)/decks/\(id)").setData([
			"added": FieldValue.serverTimestamp()
		]).done {
			self.getLoadingState.succeed()
		}.catch { error in
			self.getLoadingState.fail(error: error)
		}
		return self
	}
	
	@discardableResult
	func remove(user: User) -> Self {
		getLoadingState.startLoading()
		firestore.document("users/\(user.id)/decks/\(id)").delete().done {
			self.getLoadingState.succeed()
		}.catch { error in
			self.getLoadingState.fail(error: error)
		}
		return self
	}
	
	@discardableResult
	func setFavorite(to newValue: Bool, forUser user: User) -> Promise<Void> {
		firestore.document("users/\(user.id)/decks/\(id)").updateData([
			"favorite": newValue
		])
	}
	
	@discardableResult
	func updatePublicDataFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		topics = snapshot.get("topics") as? [String] ?? topics
		hasImage = snapshot.get("hasImage") as? Bool ?? false
		if !hasImage { image = nil }
		name = snapshot.get("name") as? String ?? name
		subtitle = snapshot.get("subtitle") as? String ?? subtitle
		description = snapshot.get("description") as? String ?? description
		numberOfViews = snapshot.get("viewCount") as? Int ?? numberOfViews
		numberOfUniqueViews = snapshot.get("uniqueViewCount") as? Int ?? numberOfUniqueViews
		numberOfRatings = snapshot.get("ratingCount") as? Int ?? numberOfRatings
		averageRating = snapshot.get("averageRating") as? Double ?? averageRating
		numberOfDownloads = snapshot.get("downloadCount") as? Int ?? numberOfDownloads
		numberOfCards = snapshot.get("cardCount") as? Int ?? numberOfCards
		numberOfCurrentUsers = snapshot.get("currentUserCount") as? Int ?? numberOfCurrentUsers
		numberOfAllTimeUsers = snapshot.get("allTimeUserCount") as? Int ?? numberOfAllTimeUsers
		dateLastUpdated = snapshot.getDate("updated") ?? dateLastUpdated
		return self
	}
	
	@discardableResult
	func updateUserDataFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		if userData == nil {
			userData = .init(snapshot: snapshot)
		} else {
			userData?.isFavorite = snapshot.get("favorite") as? Bool ?? false
			userData?.numberOfDueCards = snapshot.get("dueCardCount") as? Int ?? 0
			userData?.unlockedSections = snapshot.get("unlockedSections") as? [String] ?? []
		}
		return self
	}
	
	static func fromId(_ id: String) -> Promise<Deck> {
		var didFulfill = false
		var deck: Deck?
		return .init { seal in
			if let cachedDeck = cache[id] {
				return seal.fulfill(cachedDeck)
			}
			firestore.document("decks/\(id)").addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				if didFulfill {
					deck?.updatePublicDataFromSnapshot(snapshot)
				} else {
					didFulfill = true
					deck = .init(snapshot: snapshot)
					seal.fulfill(deck!.cache())
				}
			}
		}
	}
	
	@discardableResult
	func cache() -> Self {
		Self.cache[id] = self
		return self
	}
	
	static func == (lhs: Deck, rhs: Deck) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

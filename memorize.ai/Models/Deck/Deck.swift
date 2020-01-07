import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PromiseKit
import LoadingState

final class Deck: ObservableObject, Identifiable, Equatable, Hashable {
	static let maxNumberOfPreviewCards = 20
	
	static var cache = [String: Deck]()
	static var imageCache = [String: UIImage]()
	
	let id: String
	let creatorId: String
	let dateCreated: Date
	
	var snapshotListener: ListenerRegistration?
	
	@Published var topics: [String]
	@Published var hasImage: Bool
	@Published var image: UIImage? {
		willSet {
			displayImage = newValue.map { .init(uiImage: $0) }
		}
	}
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
	@Published var numberOfUnsectionedCards: Int {
		didSet {
			unsectionedSection.numberOfCards = numberOfUnsectionedCards
		}
	}
	@Published var numberOfCurrentUsers: Int
	@Published var numberOfAllTimeUsers: Int
	@Published var numberOfFavorites: Int
	@Published var dateLastUpdated: Date
	
	@Published var userData: UserData?
	@Published var sections: [Section]
	@Published var creator: User?
	@Published var previewCards: [Card]
	@Published var similarDecks: [Deck]
	
	@Published var imageLoadingState = LoadingState()
	@Published var userDataLoadingState = LoadingState()
	@Published var getLoadingState = LoadingState()
	@Published var sectionsLoadingState = LoadingState()
	@Published var creatorLoadingState = LoadingState()
	@Published var previewCardsLoadingState = LoadingState()
	@Published var topicsLoadingState = LoadingState()
	@Published var ratingLoadingState = LoadingState()
	@Published var similarDecksLoadingState = LoadingState()
	@Published var createSectionLoadingState = LoadingState()
	
	var displayImage: Image?
	
	lazy var unsectionedSection = Section(
		id: nil,
		parent: self,
		name: "Unsectioned",
		index: 0,
		numberOfCards: numberOfUnsectionedCards
	)
	
	init(
		id: String,
		topics: [String],
		hasImage: Bool,
		image: UIImage? = nil,
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
		numberOfUnsectionedCards: Int,
		numberOfCurrentUsers: Int,
		numberOfAllTimeUsers: Int,
		numberOfFavorites: Int,
		creatorId: String,
		dateCreated: Date,
		dateLastUpdated: Date,
		userData: UserData? = nil,
		sections: [Section] = [],
		creator: User? = nil,
		previewCards: [Card] = [],
		similarDecks: [Deck] = [],
		snapshotListener: ListenerRegistration?
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
		self.numberOfUnsectionedCards = numberOfUnsectionedCards
		self.numberOfCurrentUsers = numberOfCurrentUsers
		self.numberOfAllTimeUsers = numberOfAllTimeUsers
		self.numberOfFavorites = numberOfFavorites
		self.creatorId = creatorId
		self.dateCreated = dateCreated
		self.dateLastUpdated = dateLastUpdated
		self.userData = userData
		self.sections = sections
		self.creator = creator
		self.previewCards = previewCards
		self.similarDecks = similarDecks
		self.snapshotListener = snapshotListener
	}
	
	convenience init(snapshot: DocumentSnapshot, snapshotListener: ListenerRegistration?) {
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
			numberOfUnsectionedCards: snapshot.get("unsectionedCardCount") as? Int ?? 0,
			numberOfCurrentUsers: snapshot.get("currentUserCount") as? Int ?? 0,
			numberOfAllTimeUsers: snapshot.get("allTimeUserCount") as? Int ?? 0,
			numberOfFavorites: snapshot.get("favoriteCount") as? Int ?? 0,
			creatorId: snapshot.get("creator") as? String ?? "0",
			dateCreated: snapshot.getDate("created") ?? .now,
			dateLastUpdated: snapshot.getDate("updated") ?? .now,
			snapshotListener: snapshotListener
		)
	}
	
	#if DEBUG
	static func _new(
		id: String = "0",
		topics: [String] = [],
		hasImage: Bool = false,
		image imageName: String? = nil,
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
		numberOfUnsectionedCards: Int = 0,
		numberOfCurrentUsers: Int = 0,
		numberOfAllTimeUsers: Int = 0,
		numberOfFavorites: Int = 0,
		creatorId: String = "0",
		dateCreated: Date = .now,
		dateLastUpdated: Date = .now,
		userData: UserData? = nil,
		sections: [Section] = [],
		creator: User? = nil,
		previewCards: [Card] = [],
		similarDecks: [Deck] = [],
		snapshotListener: ListenerRegistration? = nil
	) -> Self {
		.init(
			id: id,
			topics: topics,
			hasImage: hasImage,
			image: imageName.map { .init(imageLiteralResourceName: $0) },
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
			numberOfUnsectionedCards: numberOfUnsectionedCards,
			numberOfCurrentUsers: numberOfCurrentUsers,
			numberOfAllTimeUsers: numberOfAllTimeUsers,
			numberOfFavorites: numberOfFavorites,
			creatorId: creatorId,
			dateCreated: dateCreated,
			dateLastUpdated: dateLastUpdated,
			userData: userData,
			sections: sections,
			creator: creator,
			previewCards: previewCards,
			similarDecks: similarDecks,
			snapshotListener: snapshotListener
		)
	}
	#endif
	
	var documentReference: DocumentReference {
		firestore.document("decks/\(id)")
	}
	
	var storageReference: StorageReference {
		storage.child("decks/\(id)")
	}
	
	var shareMessage: String {
		"Check out \(name) by \(creator?.name ?? "(unknown)") on memorize.ai\n\nDownload on the App Store: \(APP_STORE_URL)\nLearn more at \(WEB_URL)"
	}
	
	var nextSectionIndex: Int {
		sections.count
	}
	
	var hasUnsectionedCards: Bool {
		numberOfUnsectionedCards > 0
	}
	
	@discardableResult
	func addObserver() -> Self {
		guard snapshotListener == nil else { return self }
		snapshotListener = documentReference.addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot else { return }
			self.updatePublicDataFromSnapshot(snapshot)
		}
		return self
	}
	
	@discardableResult
	func removeObserver() -> Self {
		snapshotListener?.remove()
		snapshotListener = nil
		return self
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
				guard let image = UIImage(data: data) else {
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
			self.sections.sort { $0.index < $1.index }
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
	
	func topics(in allTopics: [Topic]) -> [Topic?] {
		topics.map { topicId in
			allTopics.first { $0.id == topicId }
		}
	}
	
	@discardableResult
	private func setRating(_ rating: Any, forUser user: User) -> PMKFinalizer {
		ratingLoadingState.startLoading()
		return user.documentReference
			.collection("decks")
			.document(id)
			.updateData(["rating": rating])
			.done {
				self.ratingLoadingState.succeed()
			}
			.catch { error in
				self.ratingLoadingState.fail(error: error)
			}
	}
	
	@discardableResult
	func addRating(_ rating: Int, forUser user: User) -> PMKFinalizer {
		setRating(rating, forUser: user)
	}
	
	@discardableResult
	func removeRating(forUser user: User) -> PMKFinalizer {
		setRating(FieldValue.delete(), forUser: user)
	}
	
	@discardableResult
	func setImage(_ image: UIImage?) -> Promise<Void> {
		guard let image = image else {
			return storageReference.delete()
		}
		guard let data = image.compressedData else {
			return .init(error: CustomError(
				message: "Malformed image data"
			))
		}
		return storageReference.putData(data, metadata: .jpeg)
	}
	
	@discardableResult
	func removeImage() -> Promise<Void> {
		setImage(nil)
	}
	
	@discardableResult
	func loadSimilarDecks() -> PMKFinalizer {
		similarDecksLoadingState.startLoading()
		return when(
			fulfilled: [
				Self.search(query: name),
				Self.search(
					filterForTopics: topics,
					sortBy: .top
				)
			] + name.split(separator: " ").compactMap { word in
				let trimmed = word.trimmingCharacters(in: .whitespaces)
				return trimmed.isEmpty
					? nil
					: Self.search(query: trimmed)
			}
		).done { result in
			self.similarDecks = Set(result.reduce([], +)).filter { $0 != self }
			self.similarDecksLoadingState.succeed()
		}.catch { error in
			self.similarDecksLoadingState.fail(error: error)
		}
	}
	
	func loadCardDrafts(forUser user: User) -> Promise<[Card.Draft]> {
		return user.documentReference
			.collection("decks/\(id)/drafts")
			.getDocuments()
			.map { snapshot in
				snapshot.documents.map { document in
					.init(parent: self, snapshot: document)
				}
			}
	}
	
	@discardableResult
	func delete() -> Self {
		_ = documentReference.delete() as Promise<Void>
		_ = firestore
			.document("users/\(creatorId)/decks/\(id)")
			.delete() as Promise<Void>
		return self
	}
	
	@discardableResult
	func get(user: User) -> Self {
		getLoadingState.startLoading()
		firestore.document("users/\(user.id)/decks/\(id)").setData([
			"added": FieldValue.serverTimestamp(),
			"dueCardCount": numberOfCards,
			"unsectionedDueCardCount": numberOfUnsectionedCards
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
		numberOf1StarRatings = snapshot.get("1StarRatingCount") as? Int ?? numberOf1StarRatings
		numberOf2StarRatings = snapshot.get("2StarRatingCount") as? Int ?? numberOf2StarRatings
		numberOf3StarRatings = snapshot.get("3StarRatingCount") as? Int ?? numberOf3StarRatings
		numberOf4StarRatings = snapshot.get("4StarRatingCount") as? Int ?? numberOf4StarRatings
		numberOf5StarRatings = snapshot.get("5StarRatingCount") as? Int ?? numberOf5StarRatings
		averageRating = snapshot.get("averageRating") as? Double ?? averageRating
		numberOfDownloads = snapshot.get("downloadCount") as? Int ?? numberOfDownloads
		numberOfCards = snapshot.get("cardCount") as? Int ?? numberOfCards
		numberOfUnsectionedCards = snapshot.get("unsectionedCardCount") as? Int ?? numberOfUnsectionedCards
		numberOfCurrentUsers = snapshot.get("currentUserCount") as? Int ?? numberOfCurrentUsers
		numberOfAllTimeUsers = snapshot.get("allTimeUserCount") as? Int ?? numberOfAllTimeUsers
		numberOfFavorites = snapshot.get("favoriteCount") as? Int ?? numberOfFavorites
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
			userData?.numberOfUnsectionedDueCards = snapshot.get("unsectionedDueCardCount") as? Int ?? 0
			userData?.sections = snapshot.get("sections") as? [String: Int] ?? [:]
			let newRating = snapshot.get("rating") as? Int
			userData?.rating = newRating == 0 ? nil : newRating
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
			var snapshotListener: ListenerRegistration?
			snapshotListener = firestore.document("decks/\(id)").addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				if didFulfill {
					deck?.updatePublicDataFromSnapshot(snapshot)
				} else {
					didFulfill = true
					deck = .init(snapshot: snapshot, snapshotListener: snapshotListener)
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
	
	@discardableResult
	func showCreateSectionAlert(
		title: String = "Create section",
		message: String? = nil,
		completion: ((String) -> Void)? = nil
	) -> Self {
		showAlert(title: title, message: message) { alert in
			alert.addTextField { textField in
				textField.placeholder = "Name"
			}
			alert.addAction(.init(title: "Cancel", style: .cancel))
			alert.addAction(.init(title: "Create", style: .default) { _ in
				guard let name = alert.textFields?.first?.text else { return }
				self.createSectionLoadingState.startLoading()
				self.documentReference.collection("sections").addDocument(data: [
					"name": name,
					"index": self.nextSectionIndex
				]).done { ref in
					self.createSectionLoadingState.succeed()
					completion?(ref.documentID)
				}.catch { error in
					self.createSectionLoadingState.fail(error: error)
				}
			})
		}
		return self
	}
	
	@discardableResult
	func showRemoveFromLibraryAlert(
		forUser user: User,
		title: String = "Remove from library",
		message: String? = "All of your data will be deleted, and all of your progress will be lost. This action cannot be undone.",
		completion: (() -> Void)? = nil
	) -> Self {
		showAlert(title: title, message: message) { alert in
			alert.addAction(.init(title: "Cancel", style: .cancel))
			alert.addAction(.init(title: "Remove", style: .destructive) { _ in
				self.remove(user: user)
				completion?()
			})
		}
		return self
	}
	
	static func == (lhs: Deck, rhs: Deck) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

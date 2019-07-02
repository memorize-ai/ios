import UIKit
import Firebase
import SafariServices
import WebKit

class DeckViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var deckImageView: UIImageView!
	@IBOutlet weak var deckImageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var deckNameLabel: UILabel!
	@IBOutlet weak var deckSubtitleLabel: UILabel!
	@IBOutlet weak var getButton: UIButton!
	@IBOutlet weak var getButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var getButtonActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var previewView: UIView!
	@IBOutlet weak var previewButtonActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var mainStarsSliderView: UIView!
	@IBOutlet weak var mainStarsSliderViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingsStarsSliderView: UIView!
	@IBOutlet weak var ratingsStarsSliderViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var mainRatingCountLabel: UILabel!
	@IBOutlet weak var ratingsRatingCountLabel: UILabel!
	@IBOutlet weak var cardCountLabel: UILabel!
	@IBOutlet weak var cardPreviewCollectionView: UICollectionView!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var descriptionLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var descriptionMoreLabel: UILabel!
	@IBOutlet weak var showFullDescriptionButton: UIButton!
	@IBOutlet weak var creatorImageView: UIImageView!
	@IBOutlet weak var creatorNameLabel: UILabel!
	@IBOutlet weak var rateDeckButton: UIButton!
	@IBOutlet weak var averageRatingLabel: UILabel!
	@IBOutlet weak var ratingsCollectionView: UICollectionView!
	@IBOutlet weak var noRatingsLabel: UILabel!
	@IBOutlet weak var infoCollectionView: UICollectionView!
	@IBOutlet weak var infoCollectionViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var moreByCreatorLabel: UILabel!
	@IBOutlet weak var moreByCreatorCollectionView: UICollectionView!
	@IBOutlet weak var similarDecksCollectionView: UICollectionView!
	
	typealias DeckUser = (id: String, image: UIImage?, name: String?, url: URL?)
	
	class Rating {
		let rating: DeckRating
		var user: DeckUser
		
		init(rating: DeckRating, user: DeckUser) {
			self.rating = rating
			self.user = user
		}
	}
	
	let RATINGS_COUNT = 10
	let CARD_PREVIEW_CELL_SPACING: CGFloat = 20
	let RATING_CELL_SPACING: CGFloat = 20
	let INFO_CELL_HEIGHT: CGFloat = 60
	let INFO_CELL_LINE_SPACING: CGFloat = 15
	let INFO_CELL_ITEM_SPACING: CGFloat = 10
	let DECK_PREVIEW_CELL_ITEM_SPACING: CGFloat = 15
	let DECK_PREVIEW_CELL_LINE_SPACING: CGFloat = 6
	
	var deck: (
		id: String?,
		hasImage: Bool?,
		image: UIImage?,
		name: String?,
		subtitle: String?,
		description: String?,
		isPublic: Bool?,
		count: Int?,
		views: DeckViews?,
		downloads: DeckDownloads?,
		ratings: DeckRatings?,
		creator: (
			id: String?,
			image: UIImage?,
			name: String?,
			url: URL?
		),
		created: Date?,
		updated: Date?
	)
	var cards = [Card]()
	var ratings = [Rating]()
	var isDescriptionExpanded = false
	var info = [[(String, String)]]()
	var creatorDecks = [Deck]()
	var similarDecks = [Deck]()
	var listeners = [String : ListenerRegistration]()
	var shouldLoadDeckAttributes = true
	var cardPreviewCells = [String : CardPreviewCollectionViewCell]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let deckId = deck.id, let hasImage = deck.hasImage else { return }
		loadFlowLayouts()
		loadCreator()
		listeners["decks/\(deckId)"] = firestore.document("decks/\(deckId)").addSnapshotListener { snapshot, error in
			if error == nil, let snapshot = snapshot, let deckName = snapshot.get("name") as? String, let subtitle = snapshot.get("subtitle") as? String, let description = snapshot.get("description") as? String, let isPublic = snapshot.get("public") as? Bool, let count = snapshot.get("count") as? Int, let creatorId = snapshot.get("creator") as? String, let created = snapshot.getDate("created"), let updated = snapshot.getDate("updated") {
				let deckViews = DeckViews(snapshot)
				let deckDownloads = DeckDownloads(snapshot)
				let deckRatings = DeckRatings(snapshot)
				self.deck.hasImage = snapshot.get("hasImage") as? Bool ?? false
				self.deck.name = deckName
				self.deck.subtitle = subtitle
				self.deck.description = description
				self.deck.isPublic = isPublic
				self.deck.count = count
				self.deck.views = deckViews
				self.deck.downloads = deckDownloads
				self.deck.ratings = deckRatings
				self.deck.creator.id = creatorId
				self.deck.created = created
				self.deck.updated = updated
				self.setLabels(name: deckName, subtitle: subtitle, description: description, ratings: deckRatings)
				self.loadInfo(isPublic: isPublic, count: count, views: deckViews, downloads: deckDownloads, ratings: deckRatings, created: created, updated: updated)
				self.loadingView.isHidden = true
				guard self.shouldLoadDeckAttributes else { return }
				self.shouldLoadDeckAttributes = false
				self.listeners["users/\(creatorId)"] = firestore.document("users/\(creatorId)").addSnapshotListener { creatorSnapshot, creatorError in
					if creatorError == nil, let creatorSnapshot = creatorSnapshot, let creatorName = creatorSnapshot.get("name") as? String, let creatorSlug = creatorSnapshot.get("slug") as? String, let creatorUrl = User.url(slug: creatorSlug) {
						self.deck.creator.name = creatorName
						self.deck.creator.url = creatorUrl
					} else {
						self.showNotification("Unable to load deck creator", type: .error)
					}
					self.loadCreator()
				}
				if let cachedImage = User.imageFromCache(creatorId) {
					self.deck.creator.image = cachedImage
					self.loadCreator()
				}
				storage.child("users/\(creatorId)").getData(maxSize: MAX_FILE_SIZE) { creatorData, creatorError in
					if creatorError == nil, let creatorData = creatorData, let creatorImage = UIImage(data: creatorData) {
						self.deck.creator.image = creatorImage
						User.cache(creatorId, image: creatorImage)
					} else {
						self.deck.creator.image = DEFAULT_PROFILE_PICTURE
						User.cache(creatorId, image: DEFAULT_PROFILE_PICTURE)
					}
					self.loadCreator()
				}
				self.listeners["decks"] = firestore.collection("decks").whereField("creator", isEqualTo: creatorId).addSnapshotListener { decksSnapshot, decksError in
					guard decksError == nil, let decksSnapshot = decksSnapshot?.documentChanges else { return }
					for deckSnapshot in decksSnapshot {
						let creatorDeck = deckSnapshot.document
						let creatorDeckId = creatorDeck.documentID
						if creatorDeckId == deckId { continue }
						switch deckSnapshot.type {
						case .added:
							let newDeck = Deck(
								id: creatorDeckId,
								hasImage: creatorDeck.get("hasImage") as? Bool ?? false,
								image: Deck.imageFromCache(creatorDeckId) ?? Deck.get(creatorDeckId)?.image ?? self.similarDecks.first { $0.id == creatorDeckId }?.image,
								name: creatorDeck.get("name") as? String ?? "Error",
								subtitle: creatorDeck.get("subtitle") as? String ?? "",
								description: creatorDeck.get("description") as? String ?? "",
								tags: creatorDeck.get("tags") as? [String] ?? [],
								isPublic: creatorDeck.get("public") as? Bool ?? true,
								count: creatorDeck.get("count") as? Int ?? 0,
								views: DeckViews(creatorDeck),
								downloads: DeckDownloads(creatorDeck),
								ratings: DeckRatings(creatorDeck),
								users: [],
								creator: creatorId,
								owner: creatorDeck.get("owner") as? String ?? "",
								created: Date(),
								updated: Date(),
								permissions: [],
								cards: [],
								mastered: 0,
								role: .none,
								hidden: false
							)
							self.creatorDecks.append(newDeck)
							self.creatorDecks.sort { $0.ratings.compare(with: $1.ratings) }
							if newDeck.hasImage {
								if let cachedImage = Deck.imageFromCache(creatorDeckId) {
									newDeck.image = cachedImage
									self.moreByCreatorCollectionView.reloadData()
								}
								storage.child("decks/\(creatorDeckId)").getData(maxSize: MAX_FILE_SIZE) { creatorData, creatorError in
									if creatorError == nil, let creatorData = creatorData, let creatorImage = UIImage(data: creatorData) {
										newDeck.image = creatorImage
										Deck.cache(creatorDeckId, image: creatorImage)
									} else {
										Deck.cache(creatorDeckId, image: DEFAULT_DECK_IMAGE)
									}
									self.moreByCreatorCollectionView.reloadData()
								}
							} else {
								newDeck.image = nil
								self.moreByCreatorCollectionView.reloadData()
							}
						case .modified:
							self.creatorDecks.first { $0.id == creatorDeckId }?.update(creatorDeck, type: .deck)
						case .removed:
							self.creatorDecks = self.creatorDecks.filter { $0.id != creatorDeckId }
						@unknown default:
							return
						}
						self.moreByCreatorCollectionView.reloadData()
					}
				}
			} else {
				let alertController = UIAlertController(title: "Error", message: "Unable to load deck. Please try again", preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
					self.navigationController?.popViewController(animated: true)
				})
				self.present(alertController, animated: true, completion: nil)
			}
		}
		listeners["decks/\(deckId)/cards"] = firestore.collection("decks/\(deckId)/cards").addSnapshotListener { snapshot, error in
			if error == nil, let snapshot = snapshot?.documentChanges {
				snapshot.forEach {
					let card = $0.document
					let cardId = card.documentID
					switch $0.type {
					case .added:
						self.cards.append(Card(
							id: cardId,
							front: card.get("front") as? String ?? "Error",
							back: card.get("back") as? String ?? "Error",
							created: card.getDate("created") ?? Date(),
							updated: card.getDate("updated") ?? Date(),
							likes: card.get("likes") as? Int ?? 0,
							dislikes: card.get("dislikes") as? Int ?? 0,
							deck: deckId
						))
					case .modified:
						self.cards.first { $0.id == cardId }?.update(card, type: .card)
					case .removed:
						self.cards = self.cards.filter { $0.id != cardId }
					@unknown default:
						return
					}
					guard let isPublic = self.deck.isPublic, let count = self.deck.count, let views = self.deck.views, let downloads = self.deck.downloads, let ratings = self.deck.ratings, let created = self.deck.created, let updated = self.deck.updated else { return }
					self.setCardLabels()
					self.loadCardPreview()
					self.loadInfo(isPublic: isPublic, count: count, views: views, downloads: downloads, ratings: ratings, created: created, updated: updated)
				}
			} else {
				self.showNotification("Unable to load cards", type: .error)
			}
		}
		loadRatings()
		if let image = deck.image {
			deckImageView.image = image
			deckImageView.layer.borderWidth = 0
		} else if hasImage {
			if let cachedImage = Deck.imageFromCache(deckId) {
				self.deckImageView.image = cachedImage
			} else {
				deckImageActivityIndicator.startAnimating()
				deckImageView.layer.borderColor = UIColor.lightGray.cgColor
				deckImageView.layer.borderWidth = 1
			}
			storage.child("decks/\(deckId)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				self.deckImageActivityIndicator.stopAnimating()
				self.deckImageView.layer.borderWidth = 0
				if error == nil, let data = data, let image = UIImage(data: data) {
					self.deckImageView.image = image
					Deck.cache(deckId, image: image)
				} else {
					self.deckImageView.image = DEFAULT_DECK_IMAGE
					Deck.cache(deckId, image: DEFAULT_DECK_IMAGE)
				}
			}
		} else {
			deckImageView.image = DEFAULT_DECK_IMAGE
		}
		navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share)), animated: false)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let deckId = deck.id else { return }
		Deck.view(deckId)
		if hasDeck {
			getButtonWidthConstraint.constant = 90
			view.layoutIfNeeded()
			getButton.setTitle("DELETE", for: .normal)
			getButton.backgroundColor = DEFAULT_RED_COLOR
		}
		ChangeHandler.updateAndCall(.deckRatingAdded) { change in
			if change == .deckRatingAdded || change == .deckRatingRemoved || change == .ratingDraftAdded || change == .ratingDraftRemoved {
				self.loadRateDeckButton()
				guard let ratings = self.deck.ratings else { return }
				self.setRatingLabels(ratings)
			}
		}
		updateCurrentViewController()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if isMovingFromParent {
			removeAllListeners()
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		if let reviewVC = segue.destination as? ReviewViewController {
			if let deckName = deck.name {
				reviewVC.previewCards = cards
				reviewVC.previewDeck = deckName
			} else {
				showNotification("Unable to load deck. Please try again", type: .error)
			}
		} else if let rateDeckVC = segue.destination as? RateDeckViewController {
			if let deckId = deck.id, let deck = Deck.get(deckId) {
				rateDeckVC.deck = deck
				rateDeckVC.previousViewController = self
			} else {
				showNotification("Unable to load deck. Please try again", type: .error)
			}
		} else if let ratingVC = segue.destination as? RatingViewController, let rating = sender as? Rating {
			ratingVC.rating = rating
		}
	}
	
	var hasDeck: Bool {
		return Deck.has(deck.id)
	}
	
	func removeAllListeners() {
		listeners.forEach { $1.remove() }
		listeners.removeAll()
	}
	
	@objc
	func share() {
		if let deckId = deck.id, let url = Deck.url(id: deckId) {
			let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
			activityVC.popoverPresentationController?.sourceView = view
			present(activityVC, animated: true, completion: nil)
		} else {
			showNotification("Unable to share deck. Please try again", type: .error)
		}
	}
	
	func loadFlowLayouts() {
		let cardPreviewCollectionViewHeight = cardPreviewCollectionView.bounds.height
		cardPreviewCollectionView.collectionViewLayout = flowLayout(
			width: cardPreviewCollectionViewHeight * 0.7,
			height: cardPreviewCollectionViewHeight,
			itemSpacing: CARD_PREVIEW_CELL_SPACING,
			lineSpacing: 0,
			scrollDirection: .horizontal,
			leftInset: 20,
			rightInset: 20
		)
		let ratingsCollectionViewHeight = ratingsCollectionView.bounds.height
		ratingsCollectionView.collectionViewLayout = flowLayout(
			width: ratingsCollectionViewHeight * 1.5,
			height: ratingsCollectionViewHeight,
			itemSpacing: RATING_CELL_SPACING,
			lineSpacing: 0,
			scrollDirection: .horizontal,
			leftInset: 20,
			rightInset: 20
		)
		infoCollectionView.collectionViewLayout = flowLayout(
			width: (infoCollectionView.bounds.width - INFO_CELL_ITEM_SPACING) / 2,
			height: INFO_CELL_HEIGHT,
			itemSpacing: INFO_CELL_ITEM_SPACING,
			lineSpacing: INFO_CELL_LINE_SPACING,
			scrollDirection: .vertical
		)
		moreByCreatorCollectionView.collectionViewLayout = flowLayout(
			width: moreByCreatorCollectionView.bounds.width * 2 / 3,
			height: (moreByCreatorCollectionView.bounds.height - DECK_PREVIEW_CELL_LINE_SPACING) / 2,
			itemSpacing: DECK_PREVIEW_CELL_ITEM_SPACING,
			lineSpacing: DECK_PREVIEW_CELL_LINE_SPACING,
			scrollDirection: .horizontal,
			leftInset: 20,
			rightInset: 20
		)
		similarDecksCollectionView.collectionViewLayout = flowLayout(
			width: similarDecksCollectionView.bounds.width * 2 / 3,
			height: (similarDecksCollectionView.bounds.height - DECK_PREVIEW_CELL_LINE_SPACING) / 2,
			itemSpacing: DECK_PREVIEW_CELL_ITEM_SPACING,
			lineSpacing: DECK_PREVIEW_CELL_LINE_SPACING,
			scrollDirection: .horizontal,
			leftInset: 20,
			rightInset: 20
		)
	}
	
	func flowLayout(width: CGFloat, height: CGFloat, itemSpacing: CGFloat, lineSpacing: CGFloat, scrollDirection: UICollectionView.ScrollDirection, leftInset: CGFloat = 0, rightInset: CGFloat = 0) -> UICollectionViewFlowLayout {
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: width, height: height)
		flowLayout.minimumInteritemSpacing = scrollDirection == .vertical ? itemSpacing : lineSpacing
		flowLayout.minimumLineSpacing = scrollDirection == .vertical ? lineSpacing : itemSpacing
		flowLayout.scrollDirection = scrollDirection
		flowLayout.sectionInset.left = leftInset
		flowLayout.sectionInset.right = rightInset
		return flowLayout
	}
	
	func loadRatings() {
		guard let deckId = deck.id else { return }
		listeners["decks/\(deckId)/users"] = firestore.collection("decks/\(deckId)/users").whereField("hasTitle", isEqualTo: true).order(by: "dateMilliseconds").limit(to: RATINGS_COUNT).addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let user = $0.document
				let userId = user.documentID
				switch $0.type {
				case .added:
					let newRating = Rating(
						rating: DeckRating(
							id: deckId,
							rating: user.get("rating") as? Int ?? 1,
							title: user.get("title") as? String ?? "",
							review: user.get("review") as? String ?? "",
							date: user.getDate("date") ?? Date()
						),
						user: (
							id: userId,
							image: nil,
							name: nil,
							url: nil
						)
					)
					self.ratings.append(newRating)
					firestore.document("users/\(userId)").addSnapshotListener { userSnapshot, userError in
						guard userError == nil, let userSnapshot = userSnapshot, let userName = userSnapshot.get("name") as? String, let userSlug = userSnapshot.get("slug") as? String, let url = User.url(slug: userSlug) else { return }
						newRating.user.name = userName
						newRating.user.url = url
						self.ratingsCollectionView.reloadData()
					}
					if let cachedImage = User.imageFromCache(userId) {
						newRating.user.image = cachedImage
						ChangeHandler.call(.ratingUserImageModified)
						self.ratingsCollectionView.reloadData()
					}
					storage.child("users/\(userId)").getData(maxSize: MAX_FILE_SIZE) { userData, userError in
						if userError == nil, let userData = userData, let userImage = UIImage(data: userData) {
							newRating.user.image = userImage
							User.cache(userId, image: userImage)
						} else {
							newRating.user.image = DEFAULT_PROFILE_PICTURE
							User.cache(userId, image: DEFAULT_PROFILE_PICTURE)
						}
						ChangeHandler.call(.ratingUserImageModified)
						self.ratingsCollectionView.reloadData()
					}
				case .modified:
					self.ratings.first { $0.user.id == userId }?.rating.update(user)
				case .removed:
					self.ratings = self.ratings.filter { $0.user.id != userId }
				@unknown default:
					return
				}
				guard let ratings = self.deck.ratings else { return }
				self.setRatingLabels(ratings)
				self.ratingsCollectionView.reloadData()
			}
		}
	}
	
	func setLabels(name: String, subtitle: String, description: String, ratings: DeckRatings) {
		deckNameLabel.text = name
		deckSubtitleLabel.text = subtitle
		previewView.isHidden = hasDeck
		loadCardPreview()
		setDescription(description)
		setCardLabels()
		setRatingLabels(ratings)
	}
	
	func loadCardPreview() {
		cards = cards.sorted { $0.dislikes < $1.dislikes }.sorted { $0.likes > $1.likes }
		cardPreviewCollectionView.reloadData()
	}
	
	func setDescription(_ description: String) {
		descriptionLabel.text = description
		if isDescriptionExpanded {
			descriptionMoreLabel.isHidden = true
			descriptionLabelHeightConstraint?.isActive = false
			view.layoutIfNeeded()
		} else {
			descriptionMoreLabel.isHidden = !descriptionLabel.isTruncated
		}
	}
	
	func loadInfo(isPublic: Bool, count: Int, views: DeckViews, downloads: DeckDownloads, ratings: DeckRatings, created: Date, updated: Date) {
		info = [
			[(isPublic ? "public" : "private", "access"), (count.formatted, "card\(count.plural)")],
			[(ratings.count.formatted, "rating\(ratings.count.plural)"), (String(ratings.average.oneDecimalPlace), "average")],
			[(downloads.total.formatted, "download\(downloads.total.plural)"), (downloads.current.formatted, "user\(downloads.current.plural)")],
			[(views.total.formatted, "view\(views.total.plural)"), (views.unique.formatted, "unique viewer\(views.unique.plural)")],
			[(updated.formatCompact(), "last updated"), (created.formatCompact(), "created")]
		]
		infoCollectionViewHeightConstraint.constant = CGFloat(info.count) * (INFO_CELL_HEIGHT + INFO_CELL_LINE_SPACING) - INFO_CELL_LINE_SPACING
		view.layoutIfNeeded()
		infoCollectionView.reloadData()
	}
	
	func setCardLabels() {
		cardCountLabel.text = "\((deck.count ?? 0).formatted) card\(deck.count?.plural ?? "s")"
	}
	
	func setRatingLabels(_ ratings: DeckRatings) {
		let formattedRatings = ratings.count.formatted
		mainRatingCountLabel.text = formattedRatings
		ratingsRatingCountLabel.text = formattedRatings
		averageRatingLabel.text = String(ratings.average.oneDecimalPlace)
		noRatingsLabel.isHidden = !self.ratings.isEmpty
		mainStarsSliderViewTrailingConstraint.constant = getStarsTrailingConstraint(width: mainStarsSliderView.bounds.width, ratings: ratings)
		ratingsStarsSliderViewTrailingConstraint.constant = getStarsTrailingConstraint(width: ratingsStarsSliderView.bounds.width, ratings: ratings)
		view.layoutIfNeeded()
	}
	
	func loadCreator() {
		creatorImageView.image = deck.creator.image ?? DEFAULT_PROFILE_PICTURE
		creatorNameLabel.text = deck.creator.name
		if let creatorName = deck.creator.name {
			moreByCreatorLabel.text = "More by \(creatorName)"
		} else {
			moreByCreatorLabel.text = nil
		}
	}
	
	func loadRateDeckButton() {
		guard let deckId = deck.id else { return }
		if RatingDraft.get(deckId) != nil {
			rateDeckButton.setTitle("Edit Draft", for: .normal)
		} else if DeckRating.get(deckId) != nil {
			rateDeckButton.setTitle("Edit Rating", for: .normal)
		} else {
			rateDeckButton.setTitle("New Rating", for: .normal)
			if !hasDeck {
				rateDeckButton.isEnabled = false
			}
		}
	}
	
	@IBAction
	func showFullDescription() {
		if let description = deck.description {
			showFullDescriptionButton.isEnabled = false
			isDescriptionExpanded = true
			setDescription(description)
		} else {
			showNotification("There was an error expanding the description. Please try again", type: .error)
		}
	}
	
	@IBAction
	func showCreatorProfile() {
		if let url = deck.creator.url {
			present(SFSafariViewController(url: url), animated: true, completion: nil)
		} else {
			showNotification("Loading creator...", type: .normal)
		}
	}
	
	@IBAction
	func rateDeck() {
		performSegue(withIdentifier: "rate", sender: self)
	}
	
	@IBAction
	func previewDeck() {
		switch deck.count {
		case .some(cards.count):
			performSegue(withIdentifier: "preview", sender: self)
		default:
			showNotification("Loading cards... \(cards.count) out of \(deck.count ?? 0)", type: .normal)
		}
	}
	
	@IBAction
	func get() {
		guard let id = id, let deckId = deck.id else { return }
		let isGet = getButton.currentTitle == "GET"
		getButton.setTitle(nil, for: .normal)
		getButtonActivityIndicator.startAnimating()
		if isGet {
			Deck.new(deckId) { error in
				if error == nil {
					self.getButtonWidthConstraint.constant = 90
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
						self.view.layoutIfNeeded()
						self.getButtonActivityIndicator.stopAnimating()
						self.getButton.setTitle("DELETE", for: .normal)
						self.getButton.backgroundColor = DEFAULT_RED_COLOR
					}, completion: nil)
				} else {
					self.getButtonActivityIndicator.stopAnimating()
					self.getButton.setTitle("GET", for: .normal)
					self.showNotification("Unable to get deck. Please try again", type: .error)
				}
			}
		} else {
			firestore.document("users/\(id)/decks/\(deckId)").updateData(["hidden": true]) { error in
				if error == nil {
					self.getButtonWidthConstraint.constant = 70
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
						self.view.layoutIfNeeded()
						self.getButtonActivityIndicator.stopAnimating()
						self.getButton.setTitle("GET", for: .normal)
						self.getButton.backgroundColor = DEFAULT_BLUE_COLOR
					}, completion: nil)
				} else {
					self.getButtonActivityIndicator.stopAnimating()
					self.getButton.setTitle("DELETE", for: .normal)
					self.showNotification("Unable to remove deck from library. Please try again", type: .error)
				}
			}
		}
	}
	
	func showOtherDeck(_ deck: Deck) {
		guard let deckVC = storyboard?.instantiateViewController(withIdentifier: "deck") as? DeckViewController else { return }
		deckVC.deck.id = deck.id
		deckVC.deck.hasImage = deck.hasImage
		deckVC.deck.image = deck.image
		navigationController?.pushViewController(deckVC, animated: true)
	}
	
	func deckPreviewCell(_ deck: Deck, cell: DeckPreviewCollectionViewCell) -> DeckPreviewCollectionViewCell {
		cell.imageView.image = deck.image ?? DEFAULT_DECK_IMAGE
		cell.nameLabel.text = deck.name
		cell.subtitleLabel.text = deck.subtitle
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch collectionView.tag {
		case cardPreviewCollectionView.tag:
			return cards.count
		case ratingsCollectionView.tag:
			return ratings.count
		case infoCollectionView.tag:
			return info.flatMap { $0 }.count
		case moreByCreatorCollectionView.tag:
			return creatorDecks.count
		case similarDecksCollectionView.tag:
			return similarDecks.count
		default:
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		switch collectionView.tag {
		case cardPreviewCollectionView.tag:
			guard let cell = _cell as? CardPreviewCollectionViewCell else { return _cell }
			let card = cards[indexPath.item]
			cell.load(card, side: .front)
			cell.playAction = { completion in
				if Audio.isPlaying {
					Audio.stop()
					cell.setPlayState(.ready)
				} else {
					cell.setPlayState(.stop)
					card.playAudio(.front) { success in
						cell.setPlayState(.ready)
						completion?()
						if !success {
							self.showNotification("Unable to play audio. Please try again", type: .error)
						}
					}
				}
			}
			cardPreviewCells[card.id] = cell
			return cell
		case ratingsCollectionView.tag:
			guard let cell = _cell as? DeckRatingCollectionViewCell else { return _cell }
			let rating = ratings[indexPath.item]
			cell.titleLabel.text = rating.rating.title
			cell.starsSliderViewTrailingConstraint.constant = getStarsTrailingConstraint(width: cell.starsSliderView.bounds.width, rating: Double(rating.rating.rating))
			cell.dateLabel.text = rating.rating.date.formatCompact()
			cell.nameLabel.text = rating.user.name
			let hasReview = rating.rating.hasReview
			cell.reviewLabel.text = hasReview ? rating.rating.review : "(no review)"
			cell.reviewLabel.textColor = hasReview ? .black : .darkGray
			cell.moreLabel.isHidden = !(hasReview && cell.reviewLabel.isTruncated)
			cell.action = {
				self.performSegue(withIdentifier: "rating", sender: rating)
			}
			return cell
		case infoCollectionView.tag:
			guard let cell = _cell as? DeckInfoCollectionViewCell else { return _cell }
			cell.load(info.flatMap { $0 }[indexPath.item])
			return cell
		case moreByCreatorCollectionView.tag:
			guard let cell = _cell as? DeckPreviewCollectionViewCell else { return _cell }
			return deckPreviewCell(creatorDecks[indexPath.item], cell: cell)
		case similarDecksCollectionView.tag:
			guard let cell = _cell as? DeckPreviewCollectionViewCell else { return _cell }
			return deckPreviewCell(similarDecks[indexPath.item], cell: cell)
		default:
			return _cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch collectionView.tag {
		case cardPreviewCollectionView.tag:
			guard let cardVC = storyboard?.instantiateViewController(withIdentifier: "card") as? CardViewController else { return }
			let card = cards[indexPath.item]
			cardVC.card = card
			cardVC.cell = cardPreviewCells[card.id]
			addChild(cardVC)
			cardVC.view.frame = view.frame
			view.addSubview(cardVC.view)
			cardVC.didMove(toParent: self)
		case ratingsCollectionView.tag:
			return
		case infoCollectionView.tag:
			return
		case moreByCreatorCollectionView.tag:
			showOtherDeck(creatorDecks[indexPath.item])
		case similarDecksCollectionView.tag:
			showOtherDeck(similarDecks[indexPath.item])
		default:
			return
		}
	}
}

class CardPreviewCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var likeCountLabel: UILabel!
	@IBOutlet weak var dislikeCountLabel: UILabel!
	
	var playAction: (((() -> Void)?) -> Void)?
	var completion: (() -> Void)?
	
	@IBAction
	func play() {
		playAction?(completion)
	}
	
	func load(_ card: Card, side: CardSide) {
		layer.borderColor = UIColor.darkGray.cgColor
		playButton.isHidden = card.getAudioUrls(side).isEmpty
		webView.render(side.text(for: card), fontSize: 40, textColor: "000", backgroundColor: "fff")
		likeCountLabel.text = card.likes.formatted
		dislikeCountLabel.text = card.dislikes.formatted
	}
	
	func setPlayState(_ playState: Audio.PlayState) {
		playButton.setImage(Audio.image(for: playState), for: .normal)
	}
}

class DeckRatingCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var starsSliderView: UIView!
	@IBOutlet weak var starsSliderViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var reviewLabel: UILabel!
	@IBOutlet weak var moreLabel: UILabel!
	
	var action: (() -> Void)?
	
	@IBAction
	func click() {
		action?()
	}
}

class DeckInfoCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var largeTextLabel: UILabel!
	@IBOutlet weak var smallTextLabel: UILabel!
	
	func load(_ tuple: (String, String)) {
		largeTextLabel.text = tuple.0
		smallTextLabel.text = tuple.1
	}
}

class DeckPreviewCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
}

import UIKit
import SafariServices

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
	@IBOutlet weak var starsSliderView: UIView!
	@IBOutlet weak var starsSliderViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingCountLabel: UILabel!
	@IBOutlet weak var cardCountLabel: UILabel!
	@IBOutlet weak var cardPreviewCollectionView: UICollectionView!
	@IBOutlet weak var descriptionTextView: UILabel!
	@IBOutlet weak var descriptionTextViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var descriptionMoreLabel: UILabel!
	@IBOutlet weak var showFullDescriptionButton: UIButton!
	@IBOutlet weak var creatorImageView: UIImageView!
	@IBOutlet weak var creatorNameLabel: UILabel!
	@IBOutlet weak var rateDeckButton: UIButton!
	@IBOutlet weak var averageRatingLabel: UILabel!
	@IBOutlet weak var ratingsCollectionView: UICollectionView!
	@IBOutlet weak var infoCollectionView: UICollectionView!
	@IBOutlet weak var moreByCreatorLabel: UILabel!
	@IBOutlet weak var moreByCreatorCollectionView: UICollectionView!
	@IBOutlet weak var similarDecksCollectionView: UICollectionView!
	
	var deck: (
		id: String?,
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
	var ratings = [DeckRating]()
	var isDescriptionExpanded = false
	var info = [[(String, String?)]]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let deckId = deck.id else { return }
		loadCreator()
		listeners["decks/\(deckId)"] = firestore.document("decks/\(deckId)").addSnapshotListener { snapshot, error in
			if error == nil, let snapshot = snapshot, let deckName = snapshot.get("name") as? String, let subtitle = snapshot.get("subtitle") as? String, let description = snapshot.get("description") as? String, let isPublic = snapshot.get("public") as? Bool, let count = snapshot.get("count") as? Int, let creatorId = snapshot.get("creator") as? String, let created = snapshot.getDate("created"), let updated = snapshot.getDate("updated") {
				let deckViews = DeckViews(snapshot)
				let deckDownloads = DeckDownloads(snapshot)
				let deckRatings = DeckRatings(snapshot)
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
				firestore.document("users/\(creatorId)").addSnapshotListener { creatorSnapshot, creatorError in
					if creatorError == nil, let creatorSnapshot = creatorSnapshot, let creatorName = creatorSnapshot.get("name") as? String, let creatorSlug = creatorSnapshot.get("slug") as? String, let creatorUrl = URL(string: "https://memorize.ai/users/\(creatorSlug)") {
						self.deck.creator.name = creatorName
						self.deck.creator.url = creatorUrl
					} else {
						self.showNotification("Unable to load deck creator", type: .error)
					}
					self.loadCreator()
				}
				storage.child("users/\(creatorId)").getData(maxSize: MAX_FILE_SIZE) { creatorData, creatorError in
					if creatorError == nil, let creatorData = creatorData, let creatorImage = UIImage(data: creatorData) {
						self.deck.creator.image = creatorImage
					} else {
						self.deck.creator.image = #imageLiteral(resourceName: "Person")
					}
					self.loadCreator()
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
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
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
		}
		if let image = deck.image {
			deckImageActivityIndicator.stopAnimating()
			deckImageView.image = image
			deckImageView.layer.borderWidth = 0
		} else if let deckId = deck.id {
			storage.child("decks/\(deckId)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				self.deckImageActivityIndicator.stopAnimating()
				self.deckImageView.layer.borderWidth = 0
				if error == nil, let data = data, let image = UIImage(data: data) {
					self.deckImageView.image = image
				} else {
					self.deckImageView.image = #imageLiteral(resourceName: "Gray Deck")
				}
			}
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let deckId = deck.id else { return }
		Deck.view(deckId)
		if hasDeck {
			getButtonWidthConstraint.constant = 90
			view.layoutIfNeeded()
			getButton.setTitle("DELETE", for: .normal)
			getButton.backgroundColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
		}
		updateCurrentViewController()
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
			} else {
				showNotification("Unable to load deck. Please try again", type: .error)
			}
		}
	}
	
	var hasDeck: Bool {
		return Deck.has(deck.id)
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
		descriptionTextView.text = description
		if isDescriptionExpanded {
			descriptionMoreLabel.isHidden = true
			descriptionTextViewHeightConstraint.isActive = false
			UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
		}
	}
	
	func loadInfo(isPublic: Bool, count: Int, views: DeckViews, downloads: DeckDownloads, ratings: DeckRatings, created: Date, updated: Date) {
		info = [
			[(isPublic ? "public" : "private", nil), (count.formatted, "cards")],
			[(ratings.count.formatted, "ratings"), (ratings.average.oneDecimalPlace, "average")],
			[(downloads.total.formatted, "total downloads"), (downloads.current.formatted, "active users")],
			[(views.total.formatted, "total views"), (views.unique.formatted, "unique viewers")],
			[(updated.formatCompact(), "last updated"), (created.formatCompact(), "created")]
		] as? [[(String, String?)]] ?? []
		infoCollectionView.reloadData()
	}
	
	func setCardLabels() {
		cardCountLabel.text = (deck.count ?? 0).formatted
	}
	
	func setRatingLabels(_ ratings: DeckRatings) {
		ratingCountLabel.text = ratings.count.formatted
		averageRatingLabel.text = String(ratings.average.oneDecimalPlace)
		starsSliderViewTrailingConstraint.constant = starsSliderView.bounds.width * (ratings.average == 0 ? 1 : CGFloat(5 - ratings.average) / 5)
		view.layoutIfNeeded()
	}
	
	func loadCreator() {
		creatorImageView.image = deck.image ?? #imageLiteral(resourceName: "Person")
		creatorNameLabel.text = deck.creator.name
		if let creatorName = deck.creator.name {
			moreByCreatorLabel.text = "More by \(creatorName)"
		} else {
			moreByCreatorLabel.text = nil
		}
	}
	
	@IBAction func showFullDescription() {
		if let description = deck.description {
			showFullDescriptionButton.isEnabled = false
			isDescriptionExpanded = true
			setDescription(description)
		} else {
			showNotification("There was an error expanding the description. Please try again", type: .error)
		}
	}
	
	@IBAction func showCreatorProfile() {
		if let url = deck.creator.url {
			present(SFSafariViewController(url: url), animated: true, completion: nil)
		} else {
			showNotification("Loading creator...", type: .normal)
		}
	}
	
	@IBAction func rateDeck() {
		performSegue(withIdentifier: "rate", sender: self)
	}
	
	@IBAction func previewDeck() {
		switch deck.count {
		case .some(cards.count):
			performSegue(withIdentifier: "preview", sender: self)
		default:
			showNotification("Loading cards... \(cards.count) out of \(deck.count ?? 0)", type: .normal)
		}
	}
	
	@IBAction func get() {
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
						self.getButton.backgroundColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
					}, completion: nil)
				} else {
					self.getButtonActivityIndicator.stopAnimating()
					self.getButton.setTitle("GET", for: .normal)
					self.showNotification("Unable to get deck. Please try again", type: .error)
				}
			}
		} else {
			firestore.document("users/\(id)/decks/\(deckId)").delete { error in
				if error == nil {
					self.getButtonWidthConstraint.constant = 70
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
						self.view.layoutIfNeeded()
						self.getButtonActivityIndicator.stopAnimating()
						self.getButton.setTitle("GET", for: .normal)
						self.getButton.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
					}, completion: nil)
				} else {
					self.getButtonActivityIndicator.stopAnimating()
					self.getButton.setTitle("DELETE", for: .normal)
					self.showNotification("Unable to remove deck from library. Please try again", type: .error)
				}
			}
		}
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		switch collectionView {
		case cardPreviewCollectionView:
			
		case ratingsCollectionView:
			
		case infoCollectionView:
			
		case moreByCreatorCollectionView:
			
		case similarDecksCollectionView:
			
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch collectionView {
		case cardPreviewCollectionView:
			
		case ratingsCollectionView:
			
		case infoCollectionView:
			
		case moreByCreatorCollectionView:
			
		case similarDecksCollectionView:
			
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		<#code#>
	}
}

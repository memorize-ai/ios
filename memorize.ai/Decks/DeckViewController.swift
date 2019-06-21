import UIKit
import Firebase
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
	@IBOutlet weak var starsSliderView: UIView!
	@IBOutlet weak var ratingCountLabel: UILabel!
	@IBOutlet weak var cardCountLabel: UILabel!
	@IBOutlet weak var cardPreviewCollectionView: UICollectionView!
	@IBOutlet weak var descriptionTextView: UILabel!
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
		ratingInfo: DeckRatings?,
		ratings: [DeckRating]?,
		creatorId: String?,
		creator: (
			image: UIImage?,
			name: String?,
			url: URL?
		),
		created: Date?,
		updated: Date?
	)
	var cards = [Card]()
	var hasDeck = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let deckId = deck.id else { return }
		listeners["decks/\(deckId)"] = firestore.document("decks/\(deckId)").addSnapshotListener { snapshot, error in
			if error == nil, let snapshot = snapshot {
				self.deckName = snapshot.get("name") as? String ?? "Error"
				self.nameLabel.text = self.deckName
				self.count = snapshot.get("count") as? Int
				self.load(snapshot.get("description") as? String ?? "An error has occurred")
				self.activityIndicator.stopAnimating()
				self.loadingView.isHidden = true
				guard let creator = snapshot.get("creator") as? String else { return }
				firestore.document("users/\(creator)").getDocument { creatorSnapshot, creatorError in
					guard creatorError == nil, let creatorSnapshot = creatorSnapshot, let creatorName = creatorSnapshot.get("name") as? String else { return }
					self.creatorLabel.text = "Created by \(creatorName)"
					self.resizeDescriptionWebView()
				}
			} else {
				self.activityIndicator.stopAnimating()
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
					self.reloadCards()
					ChangeHandler.call(.cardModified)
				case .modified:
					self.cards.first { $0.id == cardId }?.update(card, type: .card)
					self.reloadCards()
					ChangeHandler.call(.cardModified)
				case .removed:
					self.cards = self.cards.filter { return $0.id != cardId }
					self.reloadCards()
					ChangeHandler.call(.cardRemoved)
				@unknown default:
					return
				}
			}
		}
		if let image = image {
			imageActivityIndicator.stopAnimating()
			imageView.image = image
			imageView.layer.borderWidth = 0
		} else if let deckId = self.deckId {
			storage.child("decks/\(deckId)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				self.imageActivityIndicator.stopAnimating()
				self.imageView.layer.borderWidth = 0
				if error == nil, let data = data {
					self.imageView.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
				} else {
					self.imageView.image = #imageLiteral(resourceName: "Gray Deck")
				}
			}
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let deckId = deck.id else { return }
		Deck.view(deckId)
		if Deck.has(deckId) {
			getButtonWidthConstraint.constant = 90
			view.layoutIfNeeded()
			getButton.setTitle("DELETE", for: .normal)
			getButton.backgroundColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
		}
		updateCurrentViewController()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		guard let reviewVC = segue.destination as? ReviewViewController else { return }
		reviewVC.previewCards = cards
		reviewVC.previewDeck = deck.name
	}
	
	@IBAction func showFullDescription() {
		showFullDescriptionButton.isEnabled = false
		// Show full description
	}
	
	@IBAction func showCreatorProfile() {
		// Visit the creator profile on the website
	}
	
	@IBAction func rateDeck() {
		// Rate deck
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
}

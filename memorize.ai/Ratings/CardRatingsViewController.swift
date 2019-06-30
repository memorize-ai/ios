import UIKit

class CardRatingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var ratingsTableView: UITableView!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.deckModified) { change in
			if change == .deckModified || change == .deckRemoved || change == .cardRemoved || change == .cardRatingAdded || change == .cardRatingModified || change == .cardRatingRemoved {
				self.ratingsTableView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Card.all.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? CardRatingTableViewCell else { return _cell }
		let card = Card.sort(Card.all, by: .front)[indexPath.row]
		guard let deck = card.getDeck else { return cell }
		if let image = deck.image {
			cell.deckImageView.image = image
		} else if deck.hasImage {
			cell.deckImageView.image = nil
			cell.deckActivityIndicator.startAnimating()
			storage.child("decks/\(deck.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				if error == nil, let data = data, let image = UIImage(data: data) {
					cell.deckActivityIndicator.stopAnimating()
					cell.deckImageView.image = image
					deck.image = image
					Deck.cache(deck.id, image: image)
					self.ratingsTableView.reloadData()
				} else {
					Deck.cache(deck.id, image: DEFAULT_DECK_IMAGE)
				}
			}
		} else {
			cell.deckImageView.image = DEFAULT_DECK_IMAGE
			deck.image = nil
			Deck.cache(deck.id, image: DEFAULT_DECK_IMAGE)
		}
		cell.deckNameLabel.text = deck.name
		cell.cardLabel.text = card.front.clean()
		let ratingType = card.ratingType
		cell.likeButton.setImage(ratingType == .like ? #imageLiteral(resourceName: "Selected Like") : #imageLiteral(resourceName: "Unselected Like"), for: .normal)
		cell.dislikeButton.setImage(ratingType == .dislike ? #imageLiteral(resourceName: "Selected Dislike") : #imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
		cell.handler = { rating in
			let oldRating = card.ratingType
			let shouldUnrate = rating == oldRating
			if shouldUnrate {
				cell.likeButton.setImage(#imageLiteral(resourceName: "Unselected Like"), for: .normal)
				cell.dislikeButton.setImage(#imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
			} else {
				cell.likeButton.setImage(rating == .like ? #imageLiteral(resourceName: "Selected Like") : #imageLiteral(resourceName: "Unselected Like"), for: .normal)
				cell.dislikeButton.setImage(rating == .dislike ? #imageLiteral(resourceName: "Selected Dislike") : #imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
			}
			card.rate(shouldUnrate ? .none : rating) { error in
				if error == nil {
					self.showNotification("\(shouldUnrate ? "Removed from" : "Added to") \(shouldUnrate ? oldRating == .like ? "" : "dis" : rating == .like ? "" : "dis")liked cards", type: .success)
				} else {
					self.ratingsTableView.reloadData()
					self.showNotification("Unable to rate card. Please try again", type: .error)
				}
			}
		}
		return cell
	}
}

class CardRatingTableViewCell: UITableViewCell {
	@IBOutlet weak var deckImageView: UIImageView!
	@IBOutlet weak var deckActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var deckNameLabel: UILabel!
	@IBOutlet weak var cardLabel: UILabel!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var dislikeButton: UIButton!
	
	var handler: ((CardRatingType) -> Void)?
	
	@IBAction
	func like() {
		handler?(.like)
	}
	
	@IBAction
	func dislike() {
		handler?(.dislike)
	}
}

import UIKit

class DeckRatingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var ratingsTableView: UITableView!
	
	var cells = [Int : DeckRatingPreviewTableViewCell]()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.deckModified) { change in
			if change == .deckModified || change == .deckRemoved || change == .deckRatingAdded || change == .deckRatingModified || change == .deckRatingRemoved || change == .ratingDraftAdded || change == .ratingDraftModified || change == .ratingDraftRemoved {
				self.ratingsTableView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		if let rateDeckVC = segue.destination as? RateDeckViewController, let deck = sender as? Deck {
			rateDeckVC.deck = deck
		}
	}
	
	func showConfirmAlert(_ message: String, completion: @escaping (Bool) -> Void) {
		let alertController = UIAlertController(title: "Are you sure?", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion(false) })
		alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in completion(true) })
		present(alertController, animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return decks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? DeckRatingPreviewTableViewCell else { return _cell }
		let deck = decks[indexPath.row]
		if let image = deck.image {
			cell.setImage(image)
			cell.deckImageView.image = image
		} else if deck.hasImage {
			if let cachedImage = Deck.imageFromCache(deck.id) {
				cell.setImage(cachedImage)
				deck.image = cachedImage
			} else {
				cell.setImage(nil)
			}
			storage.child("decks/\(deck.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				cell.setImage(image)
				deck.image = image
				Deck.cache(deck.id, image: image)
				self.ratingsTableView.reloadData()
			}
		} else {
			cell.setImage(DEFAULT_DECK_IMAGE)
			deck.image = nil
			Deck.cache(deck.id, image: nil)
		}
		cell.deckNameLabel.text = deck.name
		if let rating = deck.rating {
			cell.ratingLabel.text = String(rating.rating)
			cell.detailLabel.text = "\(rating.date.formatCompact())\(rating.review.isEmpty ? "" : " • has review")\(deck.hasRatingDraft ? " • has draft" : "")"
		} else if let rating = deck.ratingDraft {
			cell.ratingLabel.text = rating.rating == nil ? "" : String(rating.rating ?? 0)
			cell.detailLabel.text = "\(rating.review == nil ? "" : "has review • ")unpublished"
		} else {
			cell.ratingLabel.text = ""
			cell.ratingLabel.font = UIFont(name: "Nunito-Bold", size: 40)
			cell.detailLabel.text = "unrated"
		}
		cells[indexPath.row] = cell
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "editRating", sender: decks[indexPath.row])
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete, let cell = cells[indexPath.row], let id = id else { return }
		let deck = decks[indexPath.row]
		if deck.hasRating {
			let draft = deck.ratingDraft
			let draftMessage = draft == nil ? "" : " and draft"
			showConfirmAlert("Your published rating\(draftMessage) will be deleted. This action cannot be undone") { accepted in
				if accepted {
					cell.startLoading()
					deck.unrate { error in
						if error == nil {
							if let draft = draft {
								firestore.document("users/\(id)/ratingDrafts/\(draft.id)").delete { error in
									cell.stopLoading()
									self.ratingsTableView.reloadData()
									self.showNotification(error == nil ? "Deleted rating\(draftMessage)" : "Unable to delete draft. Please try again", type: error == nil ? .success : .error)
								}
							} else {
								cell.stopLoading()
								self.ratingsTableView.reloadData()
							}
						} else {
							cell.stopLoading()
							self.showNotification("Unable to delete rating\(draftMessage). Please try again", type: .error)
						}
					}
				}
			}
		} else if let draft = deck.ratingDraft {
			showConfirmAlert("Your draft will be deleted. This action cannot be undone") { accepted in
				if accepted {
					cell.startLoading()
					firestore.document("users/\(id)/ratingDrafts/\(draft.id)").delete { error in
						cell.stopLoading()
						if error == nil {
							self.ratingsTableView.reloadData()
						} else {
							self.showNotification("Unable to delete draft. Please try again", type: .error)
						}
					}
				}
			}
		}
	}
}

class DeckRatingPreviewTableViewCell: UITableViewCell {
	@IBOutlet weak var deckImageView: UIImageView!
	@IBOutlet weak var deckNameLabel: UILabel!
	@IBOutlet weak var ratingLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var detailLabel: UILabel!
	
	func startLoading() {
		ratingLabel.isHidden = true
		activityIndicator.startAnimating()
	}
	
	func stopLoading() {
		activityIndicator.stopAnimating()
		ratingLabel.isHidden = false
	}
	
	func setImage(_ image: UIImage?) {
		layer.borderWidth = image == nil ? 1 : 0
		layer.borderColor = image == nil ? UIColor.lightGray.cgColor : nil
		deckImageView.image = image
	}
}

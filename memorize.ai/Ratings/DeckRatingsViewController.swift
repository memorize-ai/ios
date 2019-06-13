import UIKit

class DeckRatingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var ratingsTableView: UITableView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		if let rateDeckVC = segue.destination as? RateDeckViewController, let rating = sender as? DeckRating {
			rateDeckVC.rating = rating
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .deckRatingAdded || change == .deckRatingModified || change == .deckRatingRemoved {
				self.ratingsTableView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return decks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? DeckRatingPreviewTableViewCell else { return _cell }
		let deck = decks[indexPath.row]
		cell.deckNameLabel.text = deck.name
		if let rating = deck.rating {
			cell.ratingLabel.text = String(rating.rating)
			cell.detailLabel.text = "\(rating.date.format())\(rating.review.isEmpty ? "" : " • has review")\(deck.hasRatingDraft ? " • has draft" : "")"
		} else if let rating = deck.ratingDraft {
			cell.ratingLabel.text = rating.rating == nil ? "~" : String(rating.rating ?? 0)
			cell.detailLabel.text = "\(rating.review == nil ? "" : "has review • ")unpublished"
		} else {
			cell.ratingLabel.text = "~"
			cell.ratingLabel.font = UIFont(name: "Nunito-Bold", size: 40)
			cell.detailLabel.text = "unrated"
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "editRating", sender: deckRatings[indexPath.row])
	}
}

class DeckRatingPreviewTableViewCell: UITableViewCell {
	@IBOutlet weak var deckNameLabel: UILabel!
	@IBOutlet weak var ratingLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
}

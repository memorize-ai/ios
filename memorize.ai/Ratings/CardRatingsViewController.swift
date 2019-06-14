import UIKit

class CardRatingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var ratingsTableView: UITableView!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Card.all().count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? CardRatingTableViewCell else { return _cell }
		let card = Card.all()[indexPath.row]
		guard let deck = card.getDeck else { return cell }
		if let image = deck.image {
			cell.deckImageView.image = image
		} else {
			cell.deckImageView.image = nil
			cell.deckActivityIndicator.startAnimating()
			storage.child("decks/\(deck.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				cell.deckActivityIndicator.stopAnimating()
				cell.deckImageView.image = image
				deck.image = image
				self.ratingsTableView.reloadData()
			}
		}
		cell.deckNameLabel.text = deck.name
		cell.cardLabel.text = card.front.clean()
		let ratingType = card.ratingType
		cell.likeButton.setImage(ratingType == .like ? #imageLiteral(resourceName: "Selected Like") : #imageLiteral(resourceName: "Unselected Like"), for: .normal)
		cell.dislikeButton.setImage(ratingType == .dislike ? #imageLiteral(resourceName: "Selected Dislike") : #imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
		cell.handler = { rating in
			
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		
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
	
	@IBAction func like() {
		handler?(.like)
	}
	
	@IBAction func dislike() {
		handler?(.dislike)
	}
}

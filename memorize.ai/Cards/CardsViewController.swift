import UIKit
import WebKit

class CardsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var cardsCollectionView: UICollectionView!
	
	var cards = [Card]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .deckModified || change == .deckRemoved || change == .cardModified || change == .cardRemoved {
				self.loadCards()
			}
		}
		loadCards()
		updateCurrentViewController()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		guard let editCardVC = segue.destination as? EditCardViewController, let card = sender as? Card else { return }
		editCardVC.deck = card.getDeck
		editCardVC.card = card
	}
	
	func loadCards() {
		cards = Card.sort(Card.all, by: .due)
		cardsCollectionView.reloadData()
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Card.all.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? CardCollectionViewCell else { return _cell }
		let element = cards[indexPath.item]
		guard let deck = Deck.get(element.deck) else { return cell }
		cell.due(element.isDue())
		if let image = deck.image {
			cell.imageView.image = image
		} else {
			cell.imageActivityIndicator.startAnimating()
			storage.child("decks/\(deck.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				cell.imageActivityIndicator.stopAnimating()
				cell.imageView.image = image
				deck.image = image
				self.cardsCollectionView.reloadData()
			}
		}
		cell.load(element.front)
		cell.draft(element.hasDraft)
		cell.nextLabel.text = element.next.format()
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		performSegue(withIdentifier: "editCard", sender: cards[indexPath.item])
	}
}

class CardCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var draftViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var draftViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var nextLabel: UILabel!
	
	func due(_ isDue: Bool) {
		barView.backgroundColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		imageView.layer.borderWidth = 2
		imageView.layer.borderColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
	
	func load(_ text: String) {
		label.text = text.clean()
	}
	
	func draft(_ hasDraft: Bool) {
		draftViewWidthConstraint.constant = hasDraft ? 25 : 0
		draftViewTrailingConstraint.constant = hasDraft ? 10 : 0
	}
}

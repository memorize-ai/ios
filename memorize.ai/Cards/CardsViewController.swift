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
	}
	
	func loadCards() {
		cards = Card.sortDue(Card.all())
		cardsCollectionView.reloadData()
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cards.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCollectionViewCell
		let element = cards[indexPath.item]
		guard let deck = Deck.get(element.deck) else { return cell }
		cell.due(element.isDue())
		if let image = deck.image {
			cell.imageView.image = image
		} else {
			cell.imageActivityIndicator.startAnimating()
			storage.child("decks/\(deck.id)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				cell.imageActivityIndicator.stopAnimating()
				cell.imageView.image = image
				deck.image = image
			}
		}
		cell.load(element.front)
		cell.nextLabel.text = element.next.format()
		return cell
	}
}

class CardCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var nextLabel: UILabel!
	
	func due(_ isDue: Bool) {
		barView.backgroundColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		imageView.layer.borderWidth = 2
		imageView.layer.borderColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
	
	func load(_ text: String) {
		label.text = text.clean()
	}
}

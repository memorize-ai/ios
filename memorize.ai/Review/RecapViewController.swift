import UIKit

class RecapViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var recapCollectionView: UICollectionView!
	
	var cards = [(id: String, deck: Deck, card: Card, quality: Int, next: Date?)]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: true)
		let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(back))
		navigationItem.setRightBarButton(done, animated: true)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .cardModified {
				self.recapCollectionView.reloadData()
			}
		}
	}
	
	@objc func back() {
		performSegue(withIdentifier: "done", sender: self)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cards.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecapCollectionViewCell
		let element = cards[indexPath.item]
		if let image = element.deck.image {
			cell.imageView.image = image
		} else {
			cell.imageActivityIndicator.startAnimating()
			storage.child("decks/\(element.deck.id)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				element.deck.image = image
				cell.imageActivityIndicator.stopAnimating()
				cell.imageView.image = image
			}
		}
		switch element.quality {
		case 0:
			cell.layer.borderColor = #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
		case 1:
			cell.layer.borderColor = #colorLiteral(red: 0.7862434983, green: 0.4098072052, blue: 0.2144107223, alpha: 1)
		case 2:
			cell.layer.borderColor = #colorLiteral(red: 0.7540822029, green: 0.6499487758, blue: 0, alpha: 1)
		case 3:
			cell.layer.borderColor = #colorLiteral(red: 0.6504547, green: 0.7935678959, blue: 0, alpha: 1)
		case 4:
			cell.layer.borderColor = #colorLiteral(red: 0.3838550448, green: 0.7988399267, blue: 0, alpha: 1)
		case 5:
			cell.layer.borderColor = #colorLiteral(red: 0.2823529412, green: 0.8, blue: 0.4980392157, alpha: 1)
		default:
			cell.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		}
		cell.deckLabel.text = element.deck.name
		cell.cardLabel.text = element.card.front
		if let next = element.next {
			cell.nextLabel.text = next.format()
		} else {
			cell.nextLabel.text = "Loading..."
			firestore.document("users/\(id!)/decks/\(element.deck.id)/cards/\(element.card.id)/history/\(element.id)").addSnapshotListener { snapshot, error in
				guard error == nil, let next = snapshot?.get("next") as? Date else { return }
				self.cards[indexPath.item] = (id: element.id, deck: element.deck, card: element.card, quality: element.quality, next: next)
				cell.nextLabel.text = next.format()
			}
		}
		return cell
	}
}

class RecapCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var deckLabel: UILabel!
	@IBOutlet weak var cardLabel: UILabel!
	@IBOutlet weak var nextLabel: UILabel!
}

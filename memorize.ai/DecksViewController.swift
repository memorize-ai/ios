import UIKit

class DecksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var decksCollectionView: UICollectionView!
	@IBOutlet weak var cardsTableView: UITableView!
	@IBOutlet weak var startView: UIView!
	
	var deck: Deck?
	var card: Card?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 84, height: 102)
		layout.minimumLineSpacing = 8
		decksCollectionView.collectionViewLayout = layout
    }
	
	@objc @IBAction func newDeck() {
		// New Deck
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return decks.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DeckCollectionViewCell
		let element = decks[indexPath.item]
		cell.layer.borderColor = #colorLiteral(red: 0.6, green: 0.6666666667, blue: 0.7098039216, alpha: 1)
		cell.imageView.image = element.image == nil ? #imageLiteral(resourceName: "Gray Deck") : element.image
		cell.nameLabel.text = element.name
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		(collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DeckCollectionViewCell)?.layer.borderColor = #colorLiteral(red: 0.4470588235, green: 0.537254902, blue: 0.8549019608, alpha: 1)
		if !startView.isHidden {
			UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
				self.startView.alpha = 0
			}) { finished in
				if finished {
					self.startView.isHidden = true
				}
			}
			navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newDeck)), animated: true)
		}
		deck = decks[indexPath.item]
		cardsTableView.reloadData()
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		(collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DeckCollectionViewCell)?.layer.borderColor = #colorLiteral(red: 0.6, green: 0.6666666667, blue: 0.7098039216, alpha: 1)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let deck = deck else { return 0 }
		return deck.cards.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = deck?.cards[indexPath.row].front
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		card = deck?.cards[indexPath.row]
		performSegue(withIdentifier: "card", sender: self)
	}
}

class DeckCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
}

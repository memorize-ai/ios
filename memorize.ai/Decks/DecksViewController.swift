import UIKit
import FirebaseFirestore

class DecksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var decksCollectionView: UICollectionView!
	@IBOutlet weak var cardsTableView: UITableView!
	@IBOutlet weak var startView: UIView!
	
	var deck: Deck?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 84, height: 102)
		layout.minimumLineSpacing = 8
		layout.minimumInteritemSpacing = 8
		decksCollectionView.collectionViewLayout = layout
		for deck in decks {
			let deckId = deck.id
			storage.child("decks/\(deckId)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data else { return }
				decks[Deck.id(deckId)!].image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
				self.decksCollectionView.reloadData()
			}
		}
    }
	
	@objc func newDeck() {
		guard let chooseDeckTypeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chooseDeckType") as? ChooseDeckTypeViewController else { return }
		addChild(chooseDeckTypeVC)
		chooseDeckTypeVC.view.frame = view.frame
		view.addSubview(chooseDeckTypeVC.view)
		chooseDeckTypeVC.didMove(toParent: self)
	}
	
	@IBAction func edit() {
		// edit
	}
	
	@IBAction func review() {
		performSegue(withIdentifier: "review", sender: self)
	}
	
	@IBAction func createDeck() {
		performSegue(withIdentifier: "createDeck", sender: self)
	}
	
	@IBAction func searchDeck() {
		performSegue(withIdentifier: "searchDeck", sender: self)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return decks.count
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let reviewVC = segue.destination as? ReviewViewController else { return }
		reviewVC.deck = deck
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DeckCollectionViewCell
		let element = decks[indexPath.item]
		cell.layer.borderWidth = 1
		cell.layer.borderColor = #colorLiteral(red: 0.198331058, green: 0.198331058, blue: 0.198331058, alpha: 1)
		cell.imageView.image = element.image
		cell.nameLabel.text = element.name
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DeckCollectionViewCell
		cell?.layer.borderWidth = 2
		cell?.layer.borderColor = #colorLiteral(red: 0.4470588235, green: 0.537254902, blue: 0.8549019608, alpha: 1)
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
		firestore.collection("decks").document(deck!.id).collection("cards").addSnapshotListener { snapshot, error in
			guard let snapshot = snapshot?.documents, let deckId = self.deck?.id, error == nil else { return }
			self.deck?.cards = snapshot.map { card in
				let cardId = card.documentID
				firestore.collection("users").document(id!).collection("decks").document(deckId).collection("cards").document(cardId).getDocument { snapshot, error in
					guard let snapshot = snapshot?.data(), let cardIndex = self.deck?.card(id: cardId) else { return }
					self.deck?.cards[cardIndex].correct = snapshot["correct"] as? Int ?? 0
					self.deck?.cards[cardIndex].streak = snapshot["streak"] as? Int ?? 0
					self.deck?.cards[cardIndex].last = snapshot["last"] as? Timestamp ?? Timestamp()
					self.deck?.cards[cardIndex].next = snapshot["next"] as? Timestamp ?? Timestamp()
				}
				return Card(id: card.documentID, front: card["front"] as? String ?? "Error", back: card["back"] as? String ?? "Error", count: card["count"] as? Int ?? 0, correct: 0, streak: 0, last: Timestamp(), next: Timestamp(), history: [], deck: deckId)
			}
			self.cardsTableView.reloadData()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DeckCollectionViewCell
		cell?.layer.borderWidth = 1
		cell?.layer.borderColor = #colorLiteral(red: 0.1977208257, green: 0.2122347951, blue: 0.2293028235, alpha: 1)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return deck?.cards.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = deck?.cards[indexPath.row]
		cell.textLabel?.text = element?.front
		cell.detailTextLabel?.text = element?.next.format()
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let editCardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editCard") as? EditCardViewController else { return }
		editCardVC.deck = deck
		editCardVC.card = deck?.cards[indexPath.row]
		addChild(editCardVC)
		editCardVC.view.frame = view.frame
		view.addSubview(editCardVC.view)
		editCardVC.didMove(toParent: self)
	}
}

class DeckCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
}

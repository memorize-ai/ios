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
		loadDeckImages()
    }
	
	func loadDeckImages() {
		decks.forEach {
			let deckId = $0.id
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
		// TODO - edit
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
		let deckId = deck!.id
		firestore.collection("decks").document(deckId).collection("cards").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let card = $0.document
				let cardId = card.documentID
				switch $0.type {
				case .added:
					firestore.collection("users").document(id!).collection("decks").document(deckId).collection("cards").document(cardId).addSnapshotListener { cardSnapshot, cardError in
						guard cardError == nil, let cardSnapshot = cardSnapshot else { return }
						decks[Deck.id(deckId)!].cards.append(Card(id: cardId, front: card.get("front") as? String ?? "Error", back: card.get("back") as? String ?? "Error", count: cardSnapshot.get("count") as? Int ?? 0, correct: cardSnapshot.get("correct") as? Int ?? 0, streak: cardSnapshot.get("streak") as? Int ?? 0, mastered: cardSnapshot.get("mastered") as? Bool ?? false, last: cardSnapshot.get("last") as? String ?? "", history: [], deck: deckId))
						self.cardsTableView.reloadData()
						callChangeHandler(.cardAdded)
					}
				case .modified:
					let cardIndex = decks[Deck.id(deckId)!].card(id: cardId)!
					let oldCard = decks[Deck.id(deckId)!].cards[cardIndex]
					decks[Deck.id(deckId)!].cards[cardIndex].front = card.get("front") as? String ?? oldCard.front
					decks[Deck.id(deckId)!].cards[cardIndex].back = card.get("back") as? String ?? oldCard.back
					self.cardsTableView.reloadData()
					callChangeHandler(.cardModified)
				case .removed:
					decks[Deck.id(deckId)!].cards = decks[Deck.id(deckId)!].cards.filter { return $0.id != cardId }
					self.cardsTableView.reloadData()
					callChangeHandler(.cardRemoved)
				}
			}
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
		guard let element = deck?.cards[indexPath.row] else { return cell }
		cell.textLabel?.text = element.front
		firestore.collection("users").document(id!).collection("decks").document(deck!.id).collection("cards").document(element.id).collection("history").document(element.last).addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot else { return }
			cell.detailTextLabel?.text = "NEXT: \((snapshot.get("next") as? Date ?? Date()).format())"
		}
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

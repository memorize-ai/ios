import UIKit
import FirebaseFirestore

class DecksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var decksCollectionView: UICollectionView!
	@IBOutlet weak var cardsTableView: UITableView!
	@IBOutlet weak var startView: UIView!
	@IBOutlet weak var actionsCollectionView: UICollectionView!
	
	struct Action {
		let name: String
		let action: Selector
	}
	
	let actions = [
		Action(name: "EDIT", action: #selector(editDeck)),
		Action(name: "NEW CARD", action: #selector(newCard)),
		Action(name: "REVIEW", action: #selector(review))
	]
	var deck: Deck?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		loadDeckImages()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .deckModified {
				self.decksCollectionView.reloadData()
			} else if change == .deckRemoved {
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	
	func loadDeckImages() {
		decks.forEach { deck in
			let deckId = deck.id
			storage.child("decks/\(deckId)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data else { return }
				deck.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
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
	
	@objc func editDeck() {
		// TODO - edit
	}
	
	@objc func newCard() {
		guard let newCardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newCard") as? NewCardViewController else { return }
		newCardVC.deck = deck
		addChild(newCardVC)
		newCardVC.view.frame = view.frame
		view.addSubview(newCardVC.view)
		newCardVC.didMove(toParent: self)
	}
	
	@objc func review() {
		performSegue(withIdentifier: "review", sender: self)
	}
	
	@IBAction func createDeck() {
		performSegue(withIdentifier: "createDeck", sender: self)
	}
	
	@IBAction func searchDeck() {
		performSegue(withIdentifier: "searchDeck", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let reviewVC = segue.destination as? ReviewViewController else { return }
		reviewVC.deck = deck
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == decksCollectionView {
			return CGSize(width: 84, height: 102)
		} else {
			return CGSize(width: (actions[indexPath.row].name as NSString).size(withAttributes: [.font: UIFont(name: "Nunito", size: 17)!]).width + 4, height: 36)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView == decksCollectionView ? 8 : 4
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 8
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == decksCollectionView ? decks.count : actions.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == decksCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DeckCollectionViewCell
			let element = decks[indexPath.item]
			cell.layer.borderWidth = 1
			cell.layer.borderColor = #colorLiteral(red: 0.198331058, green: 0.198331058, blue: 0.198331058, alpha: 1)
			cell.imageView.image = element.image
			cell.nameLabel.text = element.name
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ActionCollectionViewCell
			let element = actions[indexPath.item]
			cell.button.setTitle(element.name, for: .normal)
			cell.action = {
				self.performSelector(onMainThread: element.action, with: nil, waitUntilDone: false)
			}
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == decksCollectionView {
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
							self.deck!.cards.append(Card(id: cardId, front: card.get("front") as? String ?? "Error", back: card.get("back") as? String ?? "Error", count: cardSnapshot.get("count") as? Int ?? 0, correct: cardSnapshot.get("correct") as? Int ?? 0, streak: cardSnapshot.get("streak") as? Int ?? 0, mastered: cardSnapshot.get("mastered") as? Bool ?? false, last: cardSnapshot.get("last") as? String ?? "", next: cardSnapshot.get("next") as? Date ?? Date(), history: [], deck: deckId))
							self.cardsTableView.reloadData()
							callChangeHandler(.cardModified)
						}
					case .modified:
						let modifiedCard = self.deck!.cards[self.deck!.card(id: cardId)!]
						if let front = card.get("front") as? String, let back = card.get("back") as? String {
							modifiedCard.front = front
							modifiedCard.back = back
						}
						self.cardsTableView.reloadData()
						callChangeHandler(.cardModified)
					case .removed:
						self.deck!.cards = self.deck!.cards.filter { return $0.id != cardId }
						self.cardsTableView.reloadData()
						callChangeHandler(.cardRemoved)
					@unknown default:
						return
					}
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if collectionView == decksCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DeckCollectionViewCell
			cell?.layer.borderWidth = 1
			cell?.layer.borderColor = #colorLiteral(red: 0.1977208257, green: 0.2122347951, blue: 0.2293028235, alpha: 1)
		}
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

class ActionCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var button: UIButton!
	
	var action: (() -> Void)?
	
	@IBAction func click() {
		action?()
	}
	
	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		setNeedsLayout()
		layoutIfNeeded()
		let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
		var frame = layoutAttributes.frame
		frame.size.width = size.width
		return layoutAttributes
	}
}

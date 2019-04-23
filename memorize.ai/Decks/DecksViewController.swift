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
	
	let actions = [Action(name: "new card", action: #selector(newCard)), Action(name: "review all", action: #selector(review)), Action(name: "visit page", action: #selector(visitPage))]
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
			} else if change == .cardModified || change == .cardRemoved {
				self.cardsTableView.reloadData()
			} else if change == .cardDue {
				self.actionsCollectionView.reloadData()
			}
		}
		decksCollectionView.reloadData()
		cardsTableView.reloadData()
		actionsCollectionView.reloadData()
	}
	
	func loadDeckImages() {
		decks.forEach { deck in
			if deck.image == nil {
				storage.child("decks/\(deck.id)").getData(maxSize: fileLimit) { data, error in
					guard error == nil, let data = data else { return }
					deck.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
					self.decksCollectionView.reloadData()
				}
			} else {
				decksCollectionView.reloadData()
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let deckVC = segue.destination as? DeckViewController, let deck = deck else { return }
		deckVC.deckId = deck.id
		deckVC.image = deck.image
	}
	
	@objc func newDeck() {
		guard let chooseDeckTypeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chooseDeckType") as? ChooseDeckTypeViewController else { return }
		addChild(chooseDeckTypeVC)
		chooseDeckTypeVC.view.frame = view.frame
		view.addSubview(chooseDeckTypeVC.view)
		chooseDeckTypeVC.didMove(toParent: self)
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
	
	@objc func visitPage() {
		performSegue(withIdentifier: "visit", sender: self)
	}
	
	@IBAction func createDeck() {
		performSegue(withIdentifier: "createDeck", sender: self)
	}
	
	@IBAction func searchDeck() {
		performSegue(withIdentifier: "searchDeck", sender: self)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return collectionView == decksCollectionView ? CGSize(width: 84, height: 102) : CGSize(width: (actions[indexPath.row].name as NSString).size(withAttributes: [.font: UIFont(name: "Nunito-ExtraBold", size: 17)!]).width + 4, height: 36)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView == decksCollectionView ? 8 : 4
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView == decksCollectionView ? 8 : 20
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
			cell.button.isEnabled = !(element.name == "review all" && Deck.allDue().isEmpty)
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
			cardsTableView.reloadData()
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
}

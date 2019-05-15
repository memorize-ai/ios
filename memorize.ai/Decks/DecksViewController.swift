import UIKit
import FirebaseFirestore
import WebKit

class DecksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	@IBOutlet weak var decksCollectionView: UICollectionView!
	@IBOutlet weak var decksCollectionViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var cardsCollectionView: UICollectionView!
	@IBOutlet weak var actionsCollectionView: UICollectionView!
	
	struct Action {
		let name: String
		let action: Selector
	}
	
	let actions = [Action(name: "new card", action: #selector(newCard)), Action(name: "review all", action: #selector(review)), Action(name: "visit page", action: #selector(visitPage))]
	var deck: Deck?
	var cardsDue = false
	var expanded = false
	
	override func viewDidLoad() {
        super.viewDidLoad()
		expand(false)
		view.layoutIfNeeded()
		deck = decks.first
		decksCollectionView.reloadData()
		cardsCollectionView.reloadData()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .deckModified {
				self.decksCollectionView.reloadData()
			} else if change == .deckRemoved {
				self.navigationController?.popViewController(animated: true)
			} else if change == .cardModified || change == .cardRemoved {
				self.cardsCollectionView.reloadData()
			} else if change == .cardDue {
				let noneDue = Deck.allDue().isEmpty
				if self.cardsDue && noneDue {
					self.actionsCollectionView.reloadData()
					self.cardsDue = false
				} else if !(self.cardsDue || noneDue) {
					self.actionsCollectionView.reloadData()
					self.cardsDue = true
				}
			}
		}
		decksCollectionView.reloadData()
		cardsCollectionView.reloadData()
		actionsCollectionView.reloadData()
		if decks.isEmpty {
			navigationController?.popViewController(animated: true)
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
	
	func createDeck() {
		performSegue(withIdentifier: "createDeck", sender: self)
	}
	
	func searchDeck() {
		performSegue(withIdentifier: "searchDeck", sender: self)
	}
	
	func expand(_ expanded: Bool) {
		self.expanded = expanded
		let toggleButton = UIButton(type: .custom)
		toggleButton.setImage(expanded ? #imageLiteral(resourceName: "White Left Arrow") : #imageLiteral(resourceName: "White Right Arrow"), for: .normal)
		toggleButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)
		toggleButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
		toggleButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
		navigationItem.setRightBarButton(UIBarButtonItem(customView: toggleButton), animated: true)
	}
	
	@objc func toggleExpand() {
		expand(!expanded)
		decksCollectionViewWidthConstraint.constant = expanded ? 2 * view.bounds.width / 3 : 100
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: view.layoutIfNeeded, completion: nil)
		decksCollectionView.reloadData()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return collectionView == decksCollectionView ? CGSize(width: expanded ? 2 * view.bounds.width / 3 - 16 : 84, height: 84) : collectionView == actionsCollectionView ? CGSize(width: (actions[indexPath.row].name as NSString).size(withAttributes: [.font: UIFont(name: "Nunito-ExtraBold", size: 17)!]).width + 4, height: 36) : CGSize(width: cardsCollectionView.bounds.width - 20, height: 37)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView == decksCollectionView ? 8 : collectionView == actionsCollectionView ? 4 : 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView == decksCollectionView ? 8 : collectionView == actionsCollectionView ? 20 : 10
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == decksCollectionView ? decks.count : collectionView == actionsCollectionView ? actions.count : deck?.cards.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == decksCollectionView {
			if expanded {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expanded", for: indexPath) as! ExpandedDeckCollectionViewCell
				let element = decks[indexPath.item]
				cell.due(!element.allDue().isEmpty)
				if let image = element.image {
					cell.imageView.image = image
				} else {
					cell.imageActivityIndicator.startAnimating()
					storage.child("decks/\(element.id)").getData(maxSize: fileLimit) { data, error in
						guard error == nil, let data = data, let image = UIImage(data: data) else { return }
						cell.imageActivityIndicator.stopAnimating()
						cell.imageView.image = image
						element.image = image
					}
				}
				cell.nameLabel.text = element.name
				cell.layer.borderWidth = element.id == deck?.id ? 2 : 0
				cell.layer.borderColor = element.id == deck?.id ? #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1) : nil
				return cell
			} else {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DeckCollectionViewCell
				let element = decks[indexPath.item]
				cell.due(!element.allDue().isEmpty)
				if let image = element.image {
					cell.imageView.image = image
				} else {
					cell.imageView.image = nil
					cell.imageActivityIndicator.startAnimating()
					storage.child("decks/\(element.id)").getData(maxSize: fileLimit) { data, error in
						guard error == nil, let data = data, let image = UIImage(data: data) else { return }
						cell.imageActivityIndicator.stopAnimating()
						cell.imageView.image = image
						element.image = image
					}
				}
				if element.id == deck?.id {
					cell.layer.borderWidth = 3
				}
				return cell
			}
		} else if collectionView == actionsCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ActionCollectionViewCell
			let element = actions[indexPath.item]
			cell.button.setTitle(element.name, for: .normal)
			cell.button.isEnabled = !(element.name == "review all" && Deck.allDue().isEmpty)
			cell.action = {
				self.performSelector(onMainThread: element.action, with: nil, waitUntilDone: false)
			}
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ThinCardCollectionViewCell
			guard let element = deck?.cards[indexPath.item] else { return cell }
			cell.due(element.isDue())
			cell.load(element.front)
			cell.action = {
				guard let editCardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editCard") as? EditCardViewController else { return }
				editCardVC.deck = self.deck
				editCardVC.card = self.deck?.cards[indexPath.item]
				self.addChild(editCardVC)
				editCardVC.view.frame = self.view.frame
				self.view.addSubview(editCardVC.view)
				editCardVC.didMove(toParent: self)
			}
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == decksCollectionView {
			deck = decks[indexPath.item]
			decksCollectionView.reloadData()
			cardsCollectionView.reloadData()
		}
	}
}

class ThinCardCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var webView: WKWebView!
	
	var action: (() -> Void)?
	
	@IBAction func click() {
		action?()
	}
	
	func due(_ isDue: Bool) {
		barView.backgroundColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
	
	func load(_ text: String) {
		webView.render(text, fontSize: 90, textColor: "333333", backgroundColor: "e7e7e7", markdown: false)
	}
}

class DeckCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	
	func due(_ isDue: Bool) {
		layer.borderWidth = isDue ? 2 : 1
		layer.borderColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
}

class ExpandedDeckCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	
	func due(_ isDue: Bool) {
		barView.backgroundColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		imageView.layer.borderWidth = 2
		imageView.layer.borderColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
}

class ActionCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var button: UIButton!
	
	var action: (() -> Void)?
	
	@IBAction func click() {
		action?()
	}
}

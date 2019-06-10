import UIKit
import Firebase
import WebKit

class DecksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	@IBOutlet weak var decksCollectionView: UICollectionView!
	@IBOutlet weak var decksCollectionViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var cardsCollectionView: UICollectionView!
	@IBOutlet weak var actionsCollectionView: UICollectionView!
	
	class Action {
		var name: String
		let action: (DecksViewController) -> () -> Void
		
		init(name: String, action: @escaping (DecksViewController) -> () -> Void) {
			self.name = name
			self.action = action
		}
	}
	
	let actions = [
		Action(name: "new card", action: newCard),
		Action(name: "review all", action: review),
		Action(name: "visit page", action: visitPage)
	]
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
					self.reloadActions()
					self.cardsDue = false
				} else if !(self.cardsDue || noneDue) {
					self.reloadActions()
					self.cardsDue = true
				}
			} else if change == .cardDraftAdded || change == .cardDraftModified || change == .cardDraftRemoved {
				self.reloadActions()
				self.cardsCollectionView.reloadData()
			}
		}
		decksCollectionView.reloadData()
		cardsCollectionView.reloadData()
		reloadActions()
		if decks.isEmpty {
			navigationController?.popViewController(animated: true)
		}
		updateCurrentViewController()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		guard let deck = deck else { return }
		if let deckVC = segue.destination as? DeckViewController {
			deckVC.deckId = deck.id
			deckVC.image = deck.image
		} else if let editCardVC = segue.destination as? EditCardViewController {
			editCardVC.deck = deck
			editCardVC.card = sender as? Card
		}
	}
	
	var itemOffset: Int {
		return deck?.canEdit == nil ? 0 : deck?.canEdit ?? false ? 0 : 1
	}
	
	@objc func newCard() {
		performSegue(withIdentifier: "editCard", sender: nil)
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
		toggleButton.widthAnchor.constraint(equalToConstant: 31.5).isActive = true
		toggleButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
		navigationItem.setRightBarButton(UIBarButtonItem(customView: toggleButton), animated: true)
	}
	
	@objc func toggleExpand() {
		expand(!expanded)
		decksCollectionViewWidthConstraint.constant = expanded ? 2 * view.bounds.width / 3 : 100
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: view.layoutIfNeeded, completion: nil)
		decksCollectionView.reloadData()
	}
	
	func reloadActions() {
		actions.first?.name = "new card\(deck?.hasCardDraft ?? false ? "*" : "")"
		actionsCollectionView.reloadData()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == actionsCollectionView, let extraBold = UIFont(name: "Nunito-ExtraBold", size: 17) {
			return CGSize(width: (actions[indexPath.row].name as NSString).size(withAttributes: [.font: extraBold]).width + 4, height: 36)
		} else {
			return collectionView == decksCollectionView
				? CGSize(width: expanded ? 2 * view.bounds.width / 3 - 16 : 84, height: 84)
				: CGSize(width: cardsCollectionView.bounds.width - 20, height: 37)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView == decksCollectionView ? 8 : collectionView == actionsCollectionView ? 4 : 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView == decksCollectionView ? 8 : collectionView == actionsCollectionView ? 20 : 10
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == decksCollectionView
			? decks.count
			: collectionView == actionsCollectionView
				? actions.count - itemOffset
				: deck?.cards.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == decksCollectionView {
			if expanded {
				let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expanded", for: indexPath)
				guard let cell = _cell as? ExpandedDeckCollectionViewCell else { return _cell }
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
				let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
				guard let cell = _cell as? DeckCollectionViewCell else { return _cell }
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
			let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
			guard let cell = _cell as? ActionCollectionViewCell else { return _cell }
			let element = actions[indexPath.item + itemOffset]
			if element.name == "new card" {
				if deck?.canEdit == nil {
					cell.activityIndicator.startAnimating()
					deck?.canEdit { canEdit, error in
						guard error == nil else { return }
						self.deck?.canEdit = canEdit
						if canEdit {
							cell.activityIndicator.stopAnimating()
							cell.button.setTitle(element.name, for: .normal)
						} else {
							self.reloadActions()
						}
					}
				} else {
					cell.button.setTitle(element.name, for: .normal)
				}
			} else {
				cell.button.setTitle(element.name, for: .normal)
			}
			cell.button.isEnabled = !(element.name == "review all" && Deck.allDue().isEmpty)
			cell.action = element.action(self)
			return cell
		} else {
			let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
			guard let cell = _cell as? ThinCardCollectionViewCell, let element = deck?.cards[indexPath.item] else { return _cell }
			cell.due(element.isDue())
			cell.load(element.front)
			cell.setDraft(element.hasDraft)
			cell.action = {
				self.performSegue(withIdentifier: "editCard", sender: self.deck?.cards[indexPath.item])
			}
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == decksCollectionView {
			deck = decks[indexPath.item]
			decksCollectionView.reloadData()
			reloadActions()
			cardsCollectionView.reloadData()
		}
	}
}

class ThinCardCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var draftImageView: UIImageView!
	@IBOutlet weak var draftImageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var draftImageViewTrailingConstraint: NSLayoutConstraint!
	
	var action: (() -> Void)?
	
	@IBAction func click() {
		action?()
	}
	
	func due(_ isDue: Bool) {
		barView.backgroundColor = isDue ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
	
	func load(_ text: String) {
		label.text = text.clean()
	}
	
	func setDraft(_ hasDraft: Bool) {
		draftImageViewWidthConstraint.constant = hasDraft ? 25 : 0
		draftImageViewTrailingConstraint.constant = hasDraft ? 6 : 0
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
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var action: (() -> Void)?
	
	@IBAction func click() {
		action?()
	}
}

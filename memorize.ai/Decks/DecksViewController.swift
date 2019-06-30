import UIKit
import Firebase
import WebKit

class DecksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	@IBOutlet weak var decksCollectionView: UICollectionView!
	@IBOutlet weak var decksCollectionViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var cardsCollectionView: UICollectionView!
	@IBOutlet weak var actionsCollectionView: UICollectionView!
	
	class Action {
		var name: String?
		var image: UIImage?
		let action: (DecksViewController) -> () -> Void
		
		init(name: String, action: @escaping (DecksViewController) -> () -> Void) {
			self.name = name
			self.action = action
		}
		
		init(image: UIImage, action: @escaping (DecksViewController) -> () -> Void) {
			self.image = image
			self.action = action
		}
	}
	
	let actions = [
		Action(name: "new card", action: newCard),
		Action(name: "edit", action: editDeck),
		Action(image: #imageLiteral(resourceName: "Ellipsis"), action: showAdvancedSettings),
		Action(name: "visit page", action: visitPage)
	]
	var deck: Deck?
	var cardsDue = false
	var expanded = false
	var originalCardsCollectionViewWidth: CGFloat?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		originalCardsCollectionViewWidth = cardsCollectionView.bounds.width
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .deckModified {
				self.decksCollectionView.reloadData()
			} else if change == .deckRemoved {
				if Deck.has(self.deck?.id) {
					self.decksCollectionView.reloadData()
				} else if let deck = decks.first {
					self.deck = deck
					self.decksCollectionView.reloadData()
					self.cardsCollectionView.reloadData()
					self.reloadActions()
				} else {
					self.deck = nil
					self.decksCollectionView.reloadData()
					self.cardsCollectionView.reloadData()
					self.navigationController?.popViewController(animated: true)
				}
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
		expand(false)
		view.layoutIfNeeded()
		if let selectedDeckId = selectedDeckId {
			deck = Deck.get(selectedDeckId) ?? decks.first
		} else {
			deck = decks.first
		}
		decksCollectionView.reloadData()
		cardsCollectionView.reloadData()
		reloadActions()
		updateCurrentViewController()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		guard let deck = deck else { return }
		if let deckVC = segue.destination as? DeckViewController {
			deckVC.deck.id = deck.id
			deckVC.deck.hasImage = deck.hasImage
			deckVC.deck.image = deck.image
		} else if let editCardVC = segue.destination as? EditCardViewController {
			editCardVC.deck = deck
			editCardVC.card = sender as? Card
		} else if let editDeckVC = segue.destination as? EditDeckViewController {
			editDeckVC.deck = deck
		} else if let deckSettingsVC = segue.destination as? DeckSettingsViewController {
			deckSettingsVC.deck = deck
		}
	}
	
	var filteredActions: [Action] {
		switch deck?.role {
		case .some(.editor), .some(.admin), .some(.owner):
			return [actions[0], actions[1], actions[2]]
		default:
			return [actions[2], actions[3]]
		}
	}
	
	func newCard() {
		performSegue(withIdentifier: "editCard", sender: self)
	}
	
	func editDeck() {
		performSegue(withIdentifier: "editDeck", sender: self)
	}
	
	func showAdvancedSettings() {
		performSegue(withIdentifier: "settings", sender: self)
	}
	
	func visitPage() {
		performSegue(withIdentifier: "visit", sender: self)
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
	
	@objc
	func toggleExpand() {
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
		switch collectionView.tag {
		case decksCollectionView.tag:
			return CGSize(width: expanded ? 2 * view.bounds.width / 3 - 16 : 84, height: 84)
		case actionsCollectionView.tag:
			guard let name = filteredActions[indexPath.item].name as NSString?, let extraBold = UIFont(name: "Nunito-ExtraBold", size: 17) else { return CGSize(width: 36, height: 36) }
			return CGSize(width: name.size(withAttributes: [.font: extraBold]).width + 4, height: 36)
		case cardsCollectionView.tag:
			return CGSize(width: (originalCardsCollectionViewWidth ?? 20) - 20, height: 37)
		default:
			return CGSize(width: 0, height: 0)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		switch collectionView.tag {
		case decksCollectionView.tag:
			return 8
		case actionsCollectionView.tag:
			return 4
		case cardsCollectionView.tag:
			return 10
		default:
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		switch collectionView.tag {
		case decksCollectionView.tag:
			return 8
		case actionsCollectionView.tag:
			return 20
		case cardsCollectionView.tag:
			return 10
		default:
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch collectionView.tag {
		case decksCollectionView.tag:
			return decks.count
		case actionsCollectionView.tag:
			return filteredActions.count
		case cardsCollectionView.tag:
			return deck?.cards.count ?? 0
		default:
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch collectionView.tag {
		case decksCollectionView.tag:
			if expanded {
				let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expanded", for: indexPath)
				guard let cell = _cell as? ExpandedDeckCollectionViewCell else { return _cell }
				let element = decks[indexPath.item]
				cell.due(!element.allDue().isEmpty)
				if let image = element.image {
					cell.imageView.image = image
				} else if element.hasImage {
					if let cachedImage = Deck.imageFromCache(element.id) {
						cell.imageView.image = cachedImage
					} else {
						cell.imageView.image = nil
						cell.imageActivityIndicator.startAnimating()
					}
					storage.child("decks/\(element.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
						guard error == nil, let data = data, let image = UIImage(data: data) else { return }
						cell.imageActivityIndicator.stopAnimating()
						cell.imageView.image = image
						element.image = image
						Deck.cache(element.id, image: image)
						self.decksCollectionView.reloadData()
					}
				} else {
					cell.imageView.image = DEFAULT_DECK_IMAGE
					element.image = nil
					Deck.cache(element.id, image: DEFAULT_DECK_IMAGE)
				}
				cell.nameLabel.text = element.name
				cell.layer.borderWidth = element.id == deck?.id ? 2 : 0
				cell.layer.borderColor = element.id == deck?.id ? DEFAULT_BLUE_COLOR.cgColor : nil
				return cell
			} else {
				let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
				guard let cell = _cell as? DeckCollectionViewCell else { return _cell }
				let element = decks[indexPath.item]
				cell.due(!element.allDue().isEmpty)
				if let image = element.image {
					cell.imageView.image = image
				} else if element.hasImage {
					if let cachedImage = Deck.imageFromCache(element.id) {
						cell.imageView.image = cachedImage
					} else {
						cell.imageView.image = nil
						cell.imageActivityIndicator.startAnimating()
					}
					storage.child("decks/\(element.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
						guard error == nil, let data = data, let image = UIImage(data: data) else { return }
						cell.imageActivityIndicator.stopAnimating()
						cell.imageView.image = image
						element.image = image
						Deck.cache(element.id, image: image)
						self.decksCollectionView.reloadData()
					}
				} else {
					cell.imageView.image = DEFAULT_DECK_IMAGE
					element.image = nil
					Deck.cache(element.id, image: DEFAULT_DECK_IMAGE)
				}
				if element.id == deck?.id {
					cell.layer.borderWidth = 3
				}
				return cell
			}
		case actionsCollectionView.tag:
			let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
			guard let cell = _cell as? ActionCollectionViewCell else { return _cell }
			cell.load(self, action: filteredActions[indexPath.item])
			return cell
		default:
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
		guard collectionView.tag == decksCollectionView.tag else { return }
		let selectedDeck = decks[indexPath.item]
		User.save(selectedDeck: selectedDeck)
		deck = selectedDeck
		decksCollectionView.reloadData()
		reloadActions()
		cardsCollectionView.reloadData()
	}
}

class ThinCardCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var draftImageView: UIImageView!
	@IBOutlet weak var draftImageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var draftImageViewTrailingConstraint: NSLayoutConstraint!
	
	var action: (() -> Void)?
	
	@IBAction
	func click() {
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
	
	var action: (() -> Void)?
	
	@IBAction
	func click() {
		action?()
	}
	
	func load(_ viewController: DecksViewController, action: DecksViewController.Action) {
		button.setTitle(action.name, for: .normal)
		button.setImage(action.image, for: .normal)
		self.action = action.action(viewController)
	}
}

import UIKit
import Firebase
import WebKit

class DecksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	@IBOutlet weak var decksCollectionView: UICollectionView!
	@IBOutlet weak var decksCollectionViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var actionsCollectionView: UICollectionView!
	@IBOutlet weak var cardsTableView: UITableView!
	
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
	
	static var decksDidChange = false
	
	let actions = [
		Action(name: "new card", action: newCard),
		Action(name: "edit", action: editDeck),
		Action(image: #imageLiteral(resourceName: "Ellipsis"), action: showAdvancedSettings),
		Action(name: "visit page", action: visitPage)
	]
	var deck: Deck?
	var cardsDue = false
	var expanded = false
	var originalCardsTableViewWidth: CGFloat?
	var startup = true
	
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
					self.cardsTableView.reloadData()
					self.reloadActions()
				} else {
					self.deck = nil
					self.decksCollectionView.reloadData()
					self.cardsTableView.reloadData()
					self.navigationController?.popViewController(animated: true)
				}
			} else if change == .cardModified || change == .cardRemoved {
				self.cardsTableView.reloadData()
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
				self.cardsTableView.reloadData()
			}
		}
		expand(false)
		if decks.isEmpty {
			navigationController?.popViewController(animated: true)
			return
		}
		if let selectedDeckId = selectedDeckId {
			deck = Deck.get(selectedDeckId) ?? decks.first
		} else {
			deck = decks.first
		}
		if DecksViewController.decksDidChange {
			decksCollectionView.reloadData()
			cardsTableView.reloadData()
			reloadActions()
			DecksViewController.decksDidChange = false
		}
		updateCurrentViewController()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard startup else { return }
		startup = false
		originalCardsTableViewWidth = cardsTableView.bounds.width
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
						element.image = cachedImage
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
					Deck.cache(element.id, image: nil)
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
						element.image = cachedImage
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
					Deck.cache(element.id, image: nil)
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

class DecksViewControllerCardTableViewCell: UITableViewCell {
	@IBOutlet weak var label: UILabel!
	
	func load(text: String, isDue: Bool, hasDraft: Bool) {
		label.text = text.clean()
		if let font = UIFont(name: "Nunito-\(isDue ? "SemiBold" : "Regular")", size: 17) {
			label.font = font
		}
		accessoryType = hasDraft ? .disclosureIndicator : .none
	}
}

class DeckCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var isDueView: UIView!
}

class ExpandedDeckCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var isDueView: UIView!
	@IBOutlet weak var nameLabel: UILabel!
}

class ActionCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
	
	func load(action: DecksViewController.Action) {
		imageView.image = action.image
		label.text = action.name
	}
}

import UIKit

class EditCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var leftArrow: UIButton!
	@IBOutlet weak var rightArrow: UIButton!
	@IBOutlet weak var sideLabel: UILabel!
	@IBOutlet weak var swapViewBottomConstraint: NSLayoutConstraint!
	
	var cardEditor: CardEditorViewController?
	var cardPreview: CardPreviewViewController?
	var deck: Deck?
	var card: Card?
	var currentView = EditCardView.editor
	var currentSide = CardSide.front
	var lastPublishedText: (front: String, back: String)?
	var views = [UIView]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
		flowLayout.scrollDirection = .horizontal
		collectionView.collectionViewLayout = flowLayout
		navigationItem.title = "\(card == nil ? "New" : "Edit") Card"
		disable(leftArrow)
		guard let cardEditor = storyboard?.instantiateViewController(withIdentifier: "cardEditor") as? CardEditorViewController, let cardPreview = storyboard?.instantiateViewController(withIdentifier: "cardPreview") as? CardPreviewViewController else { return }
		self.cardEditor = cardEditor
		self.cardPreview = cardPreview
		views = [cardEditor.view, cardPreview.view]
		loadText()
		reloadRightBarButtonItem()
		guard let id = id, let deck = deck else { return }
		cardEditor.listen { side, text in
			if let card = self.card {
				if let draft = CardDraft.get(cardId: card.id) {
					firestore.document("users/\(id)/cardDrafts/\(draft.id)").updateData([side.rawValue: text])
				} else {
					let text = cardEditor.text
					firestore.collection("users/\(id)/cardDrafts").addDocument(data: ["deck": deck.id, "card": card.id, "front": text.front, "back": text.back])
				}
			} else if let draft = CardDraft.get(deckId: deck.id) {
				firestore.document("users/\(id)/cardDrafts/\(draft.id)").updateData([side.rawValue: text])
			} else {
				let text = cardEditor.text
				firestore.collection("users/\(id)/cardDrafts").addDocument(data: ["deck": deck.id, "front": text.front, "back": text.back])
			}
			cardPreview.update(side, text: text)
			self.reloadRightBarButtonItem()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		updateCurrentViewController()
	}
	
	func loadText() {
		guard let deck = deck, let cardEditor = cardEditor, let cardPreview = cardPreview else { return }
		if let card = card {
			lastPublishedText = card.text
			let draft = CardDraft.get(cardId: card.id)
			cardEditor.update(.front, text: draft?.front ?? card.front)
			cardPreview.update(.front, text: draft?.front ?? card.front)
			cardEditor.update(.back, text: draft?.back ?? card.back)
			cardPreview.update(.back, text: draft?.back ?? card.back)
		} else if let draft = CardDraft.get(deckId: deck.id) {
			cardEditor.update(.front, text: draft.front)
			cardPreview.update(.front, text: draft.front)
			cardEditor.update(.back, text: draft.back)
			cardPreview.update(.back, text: draft.back)
		}
	}
	
	func reloadRightBarButtonItem() {
		navigationItem.setRightBarButton(UIBarButtonItem(title: "Publish", style: .done, target: self, action: card == nil ? #selector(publishNew) : #selector(publishEdit)), animated: false)
		guard let cardEditor = cardEditor, cardEditor.hasText else { return disableRightBarButtonItem() }
		guard let lastPublishedText = lastPublishedText else { return enableRightBarButtonItem() }
		if cardEditor.trimmedText == lastPublishedText {
			disableRightBarButtonItem()
		} else {
			enableRightBarButtonItem()
		}
	}
	
	@objc func publishNew() {
		guard let deck = deck, let text = cardEditor?.trimmedText else { return }
		let date = Date()
		disableRightBarButtonItem()
		firestore.collection("decks/\(deck.id)/cards").addDocument(data: ["front": text.front, "back": text.back, "created": date, "updated": date, "likes": 0, "dislikes": 0]) { error in
			if error == nil, let id = id {
				if let draft = CardDraft.get(deckId: deck.id) {
					firestore.document("users/\(id)/cardDrafts/\(draft.id)").delete()
				}
				self.navigationController?.popViewController(animated: true)
			} else {
				self.showAlert("There was an error publishing the card. Please try again.")
				self.enableRightBarButtonItem()
			}
		}
	}
	
	@objc func publishEdit() {
		guard let deck = deck, let card = card, let text = cardEditor?.trimmedText else { return }
		disableRightBarButtonItem()
		firestore.document("decks/\(deck.id)/cards/\(card.id)").updateData(["front": text.front, "back": text.back]) { error in
			if error == nil, let id = id {
				if let draft = CardDraft.get(cardId: card.id) {
					firestore.document("users/\(id)/cardDrafts/\(draft.id)").delete()
				}
				self.lastPublishedText = text
				buzz()
			} else {
				self.showAlert("There was an error publishing the card. Please try again.")
				self.enableRightBarButtonItem()
			}
		}
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		guard let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
		swapViewBottomConstraint.constant = height
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		swapViewBottomConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func enableRightBarButtonItem() {
		guard let button = navigationItem.rightBarButtonItem else { return }
		button.isEnabled = true
		button.tintColor = .white
	}
	
	func disableRightBarButtonItem() {
		guard let button = navigationItem.rightBarButtonItem else { return }
		button.isEnabled = false
		button.tintColor = #colorLiteral(red: 0.9841352105, green: 0.9841352105, blue: 0.9841352105, alpha: 1)
	}
	
	func enable(_ button: UIButton) {
		button.isEnabled = true
		button.tintColor = .darkGray
	}
	
	func disable(_ button: UIButton) {
		button.isEnabled = false
		button.tintColor = .lightGray
	}
	
	@IBAction func left() {
		disable(leftArrow)
		sideLabel.text = "~~~"
		switch currentSide {
		case .front:
			return
		case .back:
			switch currentView {
			case .editor:
				cardEditor?.swap { side in
					self.updateSide(side)
					self.enable(self.rightArrow)
				}
				cardPreview?.load(.front)
			case .preview:
				cardPreview?.swap { side in
					self.updateSide(side)
					self.enable(self.rightArrow)
				}
				cardEditor?.load(.front)
			}
		}
	}
	
	@IBAction func right() {
		disable(rightArrow)
		sideLabel.text = "~~~"
		switch currentSide {
		case .front:
			switch currentView {
			case .editor:
				cardEditor?.swap { side in
					self.updateSide(side)
					self.enable(self.leftArrow)
				}
				cardPreview?.load(.back)
			case .preview:
				cardPreview?.swap { side in
					self.updateSide(side)
					self.enable(self.leftArrow)
				}
				cardEditor?.load(.back)
			}
		case .back:
			return
		}
	}
	
	func updateSide(_ side: CardSide) {
		sideLabel.text = side.uppercased
		currentSide = side
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return views.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		cell.addSubview(views[indexPath.item])
		return cell
	}
}

enum EditCardView {
	case editor
	case preview
}

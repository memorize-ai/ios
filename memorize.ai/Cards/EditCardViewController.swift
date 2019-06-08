import UIKit

class EditCardViewController: UIViewController {
	@IBOutlet weak var scrollView: UIScrollView!
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		scrollView.backgroundColor = .orange
//		// =========
//		let numberOfPages :Int = 5
//		let padding : CGFloat = 15
//		let viewWidth = scrollView.frame.size.width - 2 * padding
//		let viewHeight = scrollView.frame.size.height - 2 * padding
//
//		var x : CGFloat = 0
//
//		for i in 0...numberOfPages{
//			let view: UIView = UIView(frame: CGRect(x: x + padding, y: padding, width: viewWidth, height: viewHeight))
//			view.backgroundColor = UIColor.blue
//			scrollView .addSubview(view)
//
//			x = view.frame.origin.x + viewWidth + padding
//		}
//
//		scrollView.contentSize = CGSize(width:x+padding, height:scrollView.frame.size.height)
//		// =========
		disable(leftArrow)
		reloadRightBarButtonItem()
		guard let cardEditor = storyboard?.instantiateViewController(withIdentifier: "cardEditor") as? CardEditorViewController, let cardPreview = storyboard?.instantiateViewController(withIdentifier: "cardPreview") as? CardPreviewViewController else { return }
		self.cardPreview = addViewController(cardPreview) as? CardPreviewViewController
		self.cardEditor = addViewController(cardEditor) as? CardEditorViewController
		loadText()
		cardEditor.listen { side, text in
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
	
	func addViewController(_ viewController: UIViewController) -> UIViewController {
		scrollView.addSubview(viewController.view)
		addChild(viewController)
		viewController.didMove(toParent: self)
		return viewController
	}
	
	func loadText() {
		guard let deck = deck, let cardEditor = cardEditor else { return }
		if let card = card {
			let draft = CardDraft.get(cardId: card.id)
			cardEditor.update(.front, text: draft?.front ?? card.front)
			cardEditor.update(.back, text: draft?.back ?? card.back)
		} else if let draft = CardDraft.get(deckId: deck.id) {
			cardEditor.update(.front, text: draft.front)
			cardEditor.update(.back, text: draft.back)
		}
	}
	
	func reloadRightBarButtonItem() {
		func setRightBarButton(_ title: String, action: Selector) {
			navigationItem.setRightBarButton(UIBarButtonItem(title: title, style: .done, target: self, action: action), animated: false)
		}
		if card == nil {
			setRightBarButton("Create", action: #selector(create))
		} else {
			setRightBarButton("Save", action: #selector(save))
		}
		if cardEditor?.hasText ?? false {
			enableRightBarButtonItem()
		} else {
			disableRightBarButtonItem()
		}
	}
	
	@objc func save() {
		guard let deck = deck, let card = card, let text = cardEditor?.trimmedText else { return }
		disableRightBarButtonItem()
		firestore.document("decks/\(deck.id)/cards/\(card.id)").updateData(["front": text.front, "back": text.back]) { error in
			guard error == nil else { return }
			buzz()
			self.reloadRightBarButtonItem()
		}
	}
	
	@objc func create() {
		guard let deck = deck, let text = cardEditor?.trimmedText else { return }
		let date = Date()
		disableRightBarButtonItem()
		firestore.collection("decks/\(deck.id)/cards").addDocument(data: ["front": text.front, "back": text.back, "created": date, "updated": date, "likes": 0, "dislikes": 0]) { error in
			guard error == nil else { return }
			buzz()
			self.reloadRightBarButtonItem()
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
}

enum EditCardView {
	case editor
	case preview
}

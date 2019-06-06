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
		reloadRightBarButtonItem()
		guard let cardEditor = storyboard?.instantiateViewController(withIdentifier: "cardEditor") as? CardEditorViewController, let cardPreview = storyboard?.instantiateViewController(withIdentifier: "cardPreview") as? CardPreviewViewController else { return }
		self.cardEditor = addViewController(cardEditor) as? CardEditorViewController
		self.cardPreview = addViewController(cardPreview) as? CardPreviewViewController
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
	
	func reloadRightBarButtonItem() {
		guard let cardEditor = cardEditor else { return }
		func setRightBarButton(_ title: String, action: Selector) {
			navigationItem.setRightBarButton(UIBarButtonItem(title: title, style: .done, target: self, action: action), animated: false)
		}
		if card == nil {
			setRightBarButton("Create", action: #selector(create))
		} else {
			setRightBarButton("Save", action: #selector(save))
		}
		navigationItem.rightBarButtonItem?.isEnabled = cardEditor.hasText
	}
	
	@objc func save() {
		guard let deck = deck, let card = card, let text = cardEditor?.trimmedText else { return }
		navigationItem.rightBarButtonItem?.isEnabled = false
		firestore.document("decks/\(deck.id)/cards/\(card.id)").updateData(["front": text.front, "back": text.back]) { error in
			guard error == nil else { return }
			self.navigationItem.rightBarButtonItem?.isEnabled = true
			buzz()
			self.reloadRightBarButtonItem()
		}
	}
	
	@objc func create() {
		guard let deck = deck, let text = cardEditor?.trimmedText else { return }
		let date = Date()
		navigationItem.rightBarButtonItem?.isEnabled = false
		firestore.collection("decks/\(deck.id)/cards").addDocument(data: ["front": text.front, "back": text.back, "created": date, "updated": date, "likes": 0, "dislikes": 0]) { error in
			guard error == nil else { return }
			self.navigationItem.rightBarButtonItem?.isEnabled = true
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
	
	@IBAction func left() {
		switch currentSide {
		case .front:
			return
		case .back:
			switch currentView {
			case .editor:
				cardEditor?.swap(completion: nil)
				cardPreview?.load(.front)
			case .preview:
				cardPreview?.swap(completion: nil)
				cardEditor?.load(.front)
			}
		}
	}
	
	@IBAction func right() {
		switch currentSide {
		case .front:
			switch currentView {
			case .editor:
				cardEditor?.swap(completion: nil)
				cardPreview?.load(.back)
			case .preview:
				cardPreview?.swap(completion: nil)
				cardEditor?.load(.back)
			}
		case .back:
			return
		}
	}
}

enum EditCardView {
	case editor
	case preview
}

import UIKit
import Firebase

class EditCardViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var editCardView: UIView!
	@IBOutlet weak var editCardViewVerticalConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var frontLabel: UILabel!
	@IBOutlet weak var frontTextView: UITextView!
	@IBOutlet weak var backLabel: UILabel!
	@IBOutlet weak var backTextView: UITextView!
	
	var deck: Deck?
	var card: Card?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		guard let card = card else { return }
		titleBar.roundCorners([.topLeft, .topRight], radius: 10)
		resetBorder(textView: frontTextView)
		resetBorder(textView: backTextView)
		frontTextView.text = card.front
		backTextView.text = card.back
		frontTextView.setKeyboard(.advanced)
		backTextView.setKeyboard(.advanced)
		editCardView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.editCardView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update(nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		updateCurrentViewController()
	}
	
	@IBAction func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.editCardView.transform = CGAffineTransform(scaleX: 0, y: 0)
			self.view.backgroundColor = .clear
		}) {
			guard $0 else { return }
			self.view.removeFromSuperview()
		}
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
			editCardViewVerticalConstraint.constant = editCardView.frame.height / 2 - height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		editCardViewVerticalConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: view.layoutIfNeeded, completion: nil)
	}
	
	@IBAction func delete() {
		if let deck = deck, deck.owner == id, let card = card {
			firestore.document("decks/\(deck.id)/cards/\(card.id)").delete { error in
				if error == nil {
					(self.parent as? DecksViewController)?.cardsCollectionView.reloadData()
					self.hide()
				} else if let error = error {
					self.showAlert(error.localizedDescription)
				}
			}
		} else {
			showAlert("You are not the owner of this deck")
		}
	}
	
	func resetBorder(textView: UITextView) {
		textView.layer.borderWidth = 1
		textView.layer.borderColor = UIColor.lightGray.cgColor
	}
	
	func selectBorder(textView: UITextView) {
		textView.layer.borderWidth = 2
		textView.layer.borderColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
	}
	
	func redBorder(textView: UITextView) {
		textView.layer.borderWidth = 2
		textView.layer.borderColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if !textView.text.trim().isEmpty {
			selectBorder(textView: textView)
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		textView.text.trim().isEmpty ? redBorder(textView: textView) : resetBorder(textView: textView)
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if let deck = deck, deck.owner == id, let card = card {
			firestore.document("decks/\(deck.id)/cards/\(card.id)").updateData(textView == frontTextView ? ["front": frontTextView.text.trim()] : ["back": backTextView.text.trim()]) { error in
				guard error == nil else { return }
				(self.parent as? DecksViewController)?.cardsCollectionView.reloadData()
			}
		} else {
			showAlert("You are not the owner of this deck")
		}
	}
}

import UIKit

class NewCardViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var newCardView: UIView!
	@IBOutlet weak var newCardViewVerticalConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var createButton: UIButton!
	@IBOutlet weak var frontLabel: UILabel!
	@IBOutlet weak var frontTextView: UITextView!
	@IBOutlet weak var backLabel: UILabel!
	@IBOutlet weak var backTextView: UITextView!
	
	var deck: Deck?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners([.topLeft, .topRight], radius: 10)
		disable()
		resetBorder(textView: frontTextView)
		resetBorder(textView: backTextView)
		frontTextView.setKeyboard(.advanced)
		backTextView.setKeyboard(.advanced)
		newCardView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.newCardView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		updateCurrentViewController()
	}
	
	@IBAction func create() {
		guard let deck = deck else { return }
		firestore.collection("decks/\(deck.id)/cards").addDocument(data: ["front": frontTextView.text.trim(), "back": backTextView.text.trim()]) { error in
			if error == nil {
				self.hide()
			} else {
				self.showAlert("Could not create card")
			}
		}
	}
	
	@IBAction func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.newCardView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) {
			guard $0 else { return }
			self.view.removeFromSuperview()
		}
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
			newCardViewVerticalConstraint.constant = newCardView.frame.height / 2 - height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		newCardViewVerticalConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: view.layoutIfNeeded, completion: nil)
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
	
	func textViewDidChange(_ textView: UITextView) {
		let selectedLabel = textView == frontTextView ? frontLabel : backLabel
		if textView.text.trim().isEmpty {
			redBorder(textView: textView)
			selectedLabel?.textColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
		} else {
			selectBorder(textView: textView)
			selectedLabel?.textColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
		}
		!(frontTextView.text.trim().isEmpty || backTextView.text.trim().isEmpty) ? enable() : disable()
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		textView.text.trim().isEmpty ? redBorder(textView: textView) : resetBorder(textView: textView)
	}
	
	func enable() {
		createButton.isEnabled = true
		createButton.setTitleColor(.white, for: .normal)
	}
	
	func disable() {
		createButton.isEnabled = false
		createButton.setTitleColor(#colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1), for: .normal)
	}
}

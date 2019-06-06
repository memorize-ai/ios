import UIKit

class EditCardViewController: UIViewController {
	
	var deck: Deck?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		updateCurrentViewController()
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
}

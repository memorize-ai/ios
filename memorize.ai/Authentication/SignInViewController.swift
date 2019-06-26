import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var emailBarView: UIView!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordBarView: UIView!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var signInButtonBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
	
	deinit {
		KeyboardHandler.removeListener(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		disable()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		KeyboardHandler.addListener(self) { direction in
			switch direction {
			case .up:
				self.keyboardWillShow()
			case .down:
				self.keyboardWillHide()
			}
		}
		updateCurrentViewController()
	}
	
	@IBAction
	func back() {
		navigationController?.popViewController(animated: true)
	}
	
	func keyboardWillShow() {
		signInButtonBottomConstraint.constant = keyboardOffset - view.safeAreaInsets.bottom
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func keyboardWillHide() {
		signInButtonBottomConstraint.constant = 145
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch textField {
		case emailTextField: enable(barView: emailBarView)
		case passwordTextField: enable(barView: passwordBarView)
		default: return
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		switch textField {
		case emailTextField: disable(barView: emailBarView)
		case passwordTextField: disable(barView: passwordBarView)
		default: return
		}
	}
	
	@IBAction
	func textFieldChanged() {
		guard let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		!(emailText.isEmpty || passwordText.isEmpty) ? enable() : disable()
	}
	
	@IBAction
	func signIn() {
		guard let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		showActivityIndicator()
		dismissKeyboard()
		auth.signIn(withEmail: emailText, password: passwordText) { user, error in
			if error == nil {
				id = user?.user.uid
				guard let id = id else { return }
				User.pushToken()
				listeners["users/\(id)"] = firestore.document("users/\(id)").addSnapshotListener { snapshot, error in
					if error == nil, let snapshot = snapshot {
						name = snapshot.get("name") as? String ?? "Error"
						email = snapshot.get("email") as? String ?? "Error"
						slug = snapshot.get("slug") as? String
						ChangeHandler.call(.profileModified)
						User.save()
						self.hideActivityIndicator()
						self.performSegue(withIdentifier: "signIn", sender: self)
					} else if let error = error {
						self.showError(error)
					}
				}
			} else if let error = error {
				self.showError(error)
			}
		}
	}
	
	func showError(_ error: Error) {
		hideActivityIndicator()
		switch error.localizedDescription {
		case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
			showNotification("No internet", type: .error)
		default:
			showNotification("Invalid email/password", type: .error)
		}
	}
	
	func showActivityIndicator() {
		signInButton.isEnabled = false
		signInButton.setTitle(nil, for: .normal)
		signInActivityIndicator.startAnimating()
	}
	
	func hideActivityIndicator() {
		signInButton.isEnabled = true
		signInButton.setTitle("SIGN UP", for: .normal)
		signInActivityIndicator.stopAnimating()
	}
	
	func enable() {
		signInButton.isEnabled = true
		signInButton.setTitleColor(#colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), for: .normal)
		signInButton.backgroundColor = .white
	}
	
	func disable() {
		signInButton.isEnabled = false
		signInButton.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
		signInButton.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
	}
	
	func enable(barView: UIView) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			barView.transform = CGAffineTransform(scaleX: 1.01, y: 2)
			barView.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
		}, completion: nil)
	}
	
	func disable(barView: UIView) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			barView.transform = .identity
			barView.backgroundColor = .lightGray
		}, completion: nil)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

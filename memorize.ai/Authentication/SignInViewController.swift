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
	
	var forgotPasswordTextField: UITextField?
	var emailText: String?
	
	deinit {
		KeyboardHandler.removeListener(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		disable()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		KeyboardHandler.addListener(self, up: keyboardWillShow, down: keyboardWillHide)
		updateCurrentViewController()
	}
	
	@IBAction
	func back() {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction
	func forgotPassword() {
		emailText = emailTextField.text
		let alertController = UIAlertController(title: "Forgot password", message: "Send a password reset email", preferredStyle: .alert)
		alertController.addTextField {
			$0.placeholder = "Email"
			$0.text = self.emailTextField.text?.trim()
			$0.keyboardType = .emailAddress
			$0.clearButtonMode = .whileEditing
			$0.addTarget(self, action: #selector(self.forgotPasswordTextFieldChanged), for: .editingChanged)
			self.forgotPasswordTextField = $0
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
			self.emailTextField.text = self.emailText ?? ""
		})
		alertController.addAction(UIAlertAction(title: "Send", style: .default) { _ in
			let email = alertController.textFields?.first?.text?.trim() ?? ""
			if email.isEmpty { return self.showNotification("Email cannot be blank", type: .error) }
			guard email.isValidEmail else { return self.showNotification("Invalid email", type: .error) }
			self.showNotification("Sending...", type: .normal)
			auth.sendPasswordReset(withEmail: email) { error in
				self.showNotification(error == nil ? "Sent. Check your email to reset your password" : "Unable to send password reset email. Please try again", type: error == nil ? .success : .error)
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	@objc
	func forgotPasswordTextFieldChanged() {
		emailTextField.text = forgotPasswordTextField?.text?.trim() ?? ""
		textFieldChanged()
	}
	
	func keyboardWillShow() {
		signInButtonBottomConstraint.constant = keyboardOffset + 10 - bottomSafeAreaInset
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func keyboardWillHide() {
		signInButtonBottomConstraint.constant = 145
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch textField {
		case emailTextField:
			enable(barView: emailBarView)
		case passwordTextField:
			enable(barView: passwordBarView)
		default:
			return
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		switch textField {
		case emailTextField:
			disable(barView: emailBarView)
		case passwordTextField:
			disable(barView: passwordBarView)
		default:
			return
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
				listeners["users/\(id)"] = firestore.document("users/\(id)").addSnapshotListener { snapshot, error in
					if error == nil, let snapshot = snapshot {
						name = snapshot.get("name") as? String ?? "Error"
						email = snapshot.get("email") as? String ?? "Error"
						slug = snapshot.get("slug") as? String
						bio = snapshot.get("bio") as? String ?? "Error"
						ChangeHandler.call(.profileModified)
						User.save()
					} else if let error = error {
						self.showError(error)
					}
				}
				firestore.document("users/\(id)").getDocument { snapshot, error in
					if error == nil, let snapshot = snapshot {
						name = snapshot.get("name") as? String ?? "Error"
						email = snapshot.get("email") as? String ?? "Error"
						slug = snapshot.get("slug") as? String
						bio = snapshot.get("bio") as? String ?? "Error"
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
		signInButton.setTitleColor(DEFAULT_BLUE_COLOR, for: .normal)
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
			barView.backgroundColor = DEFAULT_BLUE_COLOR
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

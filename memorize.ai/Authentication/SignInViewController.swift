import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var emailBarView: UIView!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordBarView: UIView!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var signInButtonBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		disable()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@IBAction func back() {
		navigationController?.popViewController(animated: true)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
			signInButtonBottomConstraint.constant = height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		signInButtonBottomConstraint.constant = 145
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
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
	
	@IBAction func textFieldChanged() {
		guard let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		!(emailText.isEmpty || passwordText.isEmpty) ? enable() : disable()
	}
	
	@IBAction func signIn() {
		guard let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		showActivityIndicator()
		dismissKeyboard()
		Auth.auth().signIn(withEmail: emailText, password: passwordText) { user, error in
			if error == nil {
				id = user?.user.uid
				pushToken()
				firestore.document("users/\(id!)").getDocument { snapshot, error in
					guard let snapshot = snapshot else { return }
					name = snapshot.get("name") as? String ?? "Error"
					saveLogin(email: emailText, password: passwordText)
					slug = snapshot.get("slug") as? String ?? "error"
					self.hideActivityIndicator()
					self.performSegue(withIdentifier: "signIn", sender: self)
				}
			} else if let error = error {
				self.hideActivityIndicator()
				switch error.localizedDescription {
				case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
					self.showAlert("No internet")
				default:
					self.showAlert("Invalid email/password")
				}
			}
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

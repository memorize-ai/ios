import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameBarView: UIView!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var emailBarView: UIView!
	@IBOutlet weak var invalidEmailLabel: UILabel!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordBarView: UIView!
	@IBOutlet weak var passwordTooShortLabel: UILabel!
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var signUpButtonBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var signUpActivityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		disable()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	@IBAction func back() {
		navigationController?.popViewController(animated: true)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
			signUpButtonBottomConstraint.constant = height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		signUpButtonBottomConstraint.constant = 145
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch textField {
		case nameTextField: enable(barView: nameBarView)
		case emailTextField: enable(barView: emailBarView)
		case passwordTextField: enable(barView: passwordBarView)
		default: return
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		switch textField {
		case nameTextField: disable(barView: nameBarView)
		case emailTextField: disable(barView: emailBarView)
		case passwordTextField: disable(barView: passwordBarView)
		default: return
		}
	}
	
	@IBAction func nameTextFieldChanged() {
		updateSignUpButton()
	}
	
	@IBAction func emailTextFieldChanged() {
		guard let emailText = emailTextField.text?.trim() else { return }
		invalidEmailLabel.isHidden = emailText.checkEmail() || emailText.isEmpty
		updateSignUpButton()
	}
	
	@IBAction func passwordTextFieldChanged() {
		guard let passwordText = passwordTextField.text?.trim() else { return }
		passwordTooShortLabel.isHidden = passwordText.count >= 6 || passwordText.isEmpty
		updateSignUpButton()
	}
	
	@IBAction func signUp() {
		guard let nameText = nameTextField.text?.trim(), let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		showActivityIndicator()
		dismissKeyboard()
		Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
			if error == nil {
				self.findLink(nameText.trimAll(), ext: nil, id: authResult!.user.uid, name: nameText, email: emailText, password: passwordText)
			} else if let error = error {
				self.hideActivityIndicator()
				switch error.localizedDescription {
				case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
					self.showAlert("No internet")
				default:
					self.showAlert("There was a problem creating a new account")
				}
			}
		}
	}
	
	func findLink(_ l: String, ext: Int?, id i: String, name n: String, email e: String, password p: String) {
		let newLink = l + (ext == nil ? "" : String(ext!))
		firestore.collection("links").document(newLink).addSnapshotListener { snapshot, error in
			if snapshot?.exists ?? false {
				self.findLink(l, ext: (ext ?? -1) + 1, id: i, name: n, email: e, password: p)
			} else {
				id = i
				firestore.collection("users").document(id!).setData(["name": n, "email": e, "link": newLink])
				name = n
				saveLogin(email: e, password: p)
				link = newLink
				self.hideActivityIndicator()
				self.performSegue(withIdentifier: "signUp", sender: self)
			}
		}
	}
	
	func showActivityIndicator() {
		signUpButton.isEnabled = false
		signUpButton.setTitle(nil, for: .normal)
		signUpActivityIndicator.startAnimating()
	}
	
	func hideActivityIndicator() {
		signUpButton.isEnabled = true
		signUpButton.setTitle("SIGN UP", for: .normal)
		signUpActivityIndicator.stopAnimating()
	}
	
	func enable() {
		signUpButton.isEnabled = true
		signUpButton.setTitleColor(#colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), for: .normal)
		signUpButton.backgroundColor = .white
	}
	
	func disable() {
		signUpButton.isEnabled = false
		signUpButton.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
		signUpButton.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
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
	
	func updateSignUpButton() {
		guard let nameText = nameTextField.text?.trim(), let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		!nameText.isEmpty && emailText.checkEmail() && passwordText.count >= 6 ? enable() : disable()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

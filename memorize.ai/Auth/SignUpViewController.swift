import UIKit
import Firebase

class SignUpViewController: UIViewController {
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
		updateChangeHandler(nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.isNavigationBarHidden = false
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
	
	@IBAction func nameTextFieldChanged() {
		guard let nameText = nameTextField.text?.trim() else { return }
		nameText.isEmpty ? disable(barView: nameBarView) : enable(barView: nameBarView)
		updateSignUpButton()
	}
	
	@IBAction func emailTextFieldChanged() {
		guard let emailText = emailTextField.text?.trim() else { return }
		if !(emailText.checkEmail() || emailText.isEmpty) {
			emailErrorLabel.isHidden = false
			emailErrorLabel.text = "Invalid email"
		} else if User.email(emailText) != nil {
			emailErrorLabel.isHidden = false
			emailErrorLabel.text = "Email taken"
		} else {
			emailErrorLabel.isHidden = true
		}
		updateSignUpButton()
	}
	
	@IBAction func passwordTextFieldChanged() {
		guard let passwordText = passwordTextField.text?.trim() else { return }
		passwordErrorLabel.isHidden = passwordText.isEmpty || passwordText.count >= 6
		updateSignUpButton()
	}
	
	@IBAction func signUp() {
		guard let nameText = nameTextField.text?.trim(), let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		showActivityIndicator()
		dismissKeyboard()
		Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
			if error == nil {
				id = authResult?.user.uid
				ref.child("users/\(id!)").setValue(["name": nameText, "email": emailText])
				name = nameText
				saveLogin(email: emailText, password: passwordText)
				loadData()
				self.hideActivityIndicator()
				self.performSegue(withIdentifier: "signUp", sender: self)
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
		signUpButton.setTitleColor(UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1), for: .normal)
		signUpButton.backgroundColor = .white
	}
	
	func disable() {
		signUpButton.isEnabled = false
		signUpButton.setTitleColor(UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1), for: .normal)
		signUpButton.backgroundColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
	}
	
	func enable(barView: UIView) {
		
	}
	
	func disable(barView: UIView) {
		
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

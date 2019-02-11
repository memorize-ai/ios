import UIKit
import Firebase

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
	@IBOutlet weak var pictureImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var linkTextField: UITextField!
	@IBOutlet weak var takenLabel: UILabel!
	@IBOutlet weak var linkActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var linkImageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.setRightBarButton(UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)), animated: true)
		textFieldDidEndEditing(linkTextField)
    }
	
	@objc func signOut() {
		let alertController = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let signOut = UIAlertAction(title: "Sign Out", style: .default) { action in
			do {
				try Auth.auth().signOut()
				deleteLogin()
				self.performSegue(withIdentifier: "signOut", sender: self)
			} catch let error {
				self.showAlert(error.localizedDescription)
			}
		}
		alertController.addAction(cancel)
		alertController.addAction(signOut)
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func chooseImage() {
		let picker = UIImagePickerController()
		picker.delegate = self
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Camera", style: .default) { action in
			picker.sourceType = .camera
			self.present(picker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { action in
			picker.sourceType = .photoLibrary
			self.present(picker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			pictureImageView.image = image
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func resetImage() {
		pictureImageView.image = #imageLiteral(resourceName: "Person")
	}
	
	@IBAction func linkChanged() {
		// check if link is taken
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		linkTextField.layer.borderWidth = 2
		linkTextField.layer.borderColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		linkTextField.layer.borderWidth = 1
		linkTextField.layer.borderColor = UIColor.lightGray.cgColor
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

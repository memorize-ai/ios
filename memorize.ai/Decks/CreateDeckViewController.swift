import UIKit
import FirebaseFirestore
import FirebaseStorage

class CreateDeckViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
	@IBOutlet weak var outerImageView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var changeButton: UIButton!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameBarView: UIView!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var publicSwitch: UISwitch!
	@IBOutlet weak var privateSwitch: UISwitch!
	@IBOutlet weak var createButton: UIButton!
	@IBOutlet weak var createActivityIndicator: UIActivityIndicatorView!
	
	var isPublic = true
	
	override func viewDidLoad() {
        super.viewDidLoad()
		disable()
		let cornerRadius = outerImageView.bounds.width / 2
		outerImageView.layer.cornerRadius = cornerRadius
		imageView.layer.cornerRadius = cornerRadius
		imageView.layer.borderWidth = 0.5
		imageView.layer.borderColor = UIColor.lightGray.cgColor
		changeButton.roundCorners([.bottomLeft, .bottomRight], radius: cornerRadius)
		textViewDidEndEditing(descriptionTextView)
    }
	
	@IBAction func chooseImage() {
		let picker = UIImagePickerController()
		picker.delegate = self
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
			picker.sourceType = .camera
			self.present(picker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Choose Photo", style: .default) { _ in
			picker.sourceType = .photoLibrary
			self.present(picker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
			self.imageView.image = #imageLiteral(resourceName: "Gray Deck")
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			imageView.image = image
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.nameBarView.transform = CGAffineTransform(scaleX: 1.01, y: 2)
			self.nameBarView.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
		}, completion: nil)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.nameBarView.transform = .identity
			self.nameBarView.backgroundColor = .lightGray
		}, completion: nil)
	}
	
	@IBAction func nameChanged() {
		guard let nameText = nameTextField.text?.trim() else { return }
		nameText.isEmpty ? disable() : enable()
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		textView.layer.borderWidth = 2
		textView.layer.borderColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		descriptionTextView.layer.borderWidth = 1
		descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
	}
	
	@IBAction func publicSwitchChanged() {
		privateSwitch.setOn(!privateSwitch.isOn, animated: true)
		isPublic = !isPublic
	}
	
	@IBAction func privateSwitchChanged() {
		publicSwitch.setOn(!publicSwitch.isOn, animated: true)
		isPublic = !isPublic
	}
	
	@IBAction func create() {
		guard let image = imageView.image?.pngData(), let nameText = nameTextField.text?.trim() else { return }
		showActivityIndicator()
		dismissKeyboard()
		let metadata = StorageMetadata()
		metadata.contentType = "image/png"
		var deckRef: DocumentReference?
		deckRef = firestore.collection("decks").addDocument(data: ["name": nameText, "description": descriptionTextView.text.trim(), "public": isPublic, "count": 0, "creator": id!, "owner": id!]) { error in
			guard error == nil, let deckId = deckRef?.documentID else { return }
			firestore.collection("users").document(id!).collection("decks").document(deckId).setData(["mastered": 0])
			storage.child("decks/\(deckId)").putData(image, metadata: metadata) { metadata, error in
				if error == nil {
					self.hideActivityIndicator()
					self.navigationController?.popViewController(animated: true)
				} else if let error = error {
					self.hideActivityIndicator()
					switch error.localizedDescription {
					case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
						self.showAlert("No internet")
					default:
						self.showAlert("There was a problem creating a new deck")
					}
				}
			}
		}
	}
	
	func showActivityIndicator() {
		createButton.isEnabled = false
		createButton.setTitle(nil, for: .normal)
		createActivityIndicator.startAnimating()
	}
	
	func hideActivityIndicator() {
		createButton.isEnabled = true
		createButton.setTitle("CREATE", for: .normal)
		createActivityIndicator.stopAnimating()
	}
	
	func enable() {
		createButton.isEnabled = true
		createButton.setTitleColor(.white, for: .normal)
		createButton.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
	}
	
	func disable() {
		createButton.isEnabled = false
		createButton.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
		createButton.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

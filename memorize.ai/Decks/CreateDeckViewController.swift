import UIKit
import Firebase

class CreateDeckViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
	@IBOutlet weak var outerImageView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var changeButton: UIButton!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameBarView: UIView!
	@IBOutlet weak var subtitleCharactersRemainingLabel: UILabel!
	@IBOutlet weak var subtitleTextField: UITextField!
	@IBOutlet weak var subtitleBarView: UIView!
	@IBOutlet weak var tagsRemainingLabel: UILabel!
	@IBOutlet weak var tagsTextView: UITextView!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var publicSwitch: UISwitch!
	@IBOutlet weak var privateSwitch: UISwitch!
	@IBOutlet weak var createButton: UIButton!
	@IBOutlet weak var createActivityIndicator: UIActivityIndicatorView!
	
	let SUBTITLE_LENGTH = 60
	let TAGS_COUNT = 20
	var hasTagsPlaceholder = true
	var lastTags = ""
	var lastSubtitle = ""
	var isPublic = true
	
	override func viewDidLoad() {
        super.viewDidLoad()
		disable()
		imageView.layer.borderColor = UIColor.lightGray.cgColor
		createButton.layer.borderColor = UIColor.lightGray.cgColor
		imageView.layer.masksToBounds = true
		nameTextField.setKeyboard()
		textViewDidEndEditing(tagsTextView)
		textViewDidEndEditing(descriptionTextView)
		tagsTextView.setKeyboard(.plain)
		descriptionTextView.setKeyboard(.advanced)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCurrentViewController()
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
		let barView = textField == nameTextField ? nameBarView : subtitleBarView
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			barView?.transform = CGAffineTransform(scaleX: 1.01, y: 2)
			barView?.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
		}, completion: nil)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		let barView = textField == nameTextField ? nameBarView : subtitleBarView
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			barView?.transform = .identity
			barView?.backgroundColor = .lightGray
		}, completion: nil)
	}
	
	@IBAction func nameChanged() {
		guard let nameText = nameTextField.text?.trim() else { return }
		nameText.isEmpty ? disable() : enable()
	}
	
	@IBAction func subtitleChanged() {
		guard let subtitleText = subtitleTextField.text else { return }
		let difference = SUBTITLE_LENGTH - subtitleText.trim().count
		if difference < 0 {
			subtitleTextField.text = lastSubtitle
		} else {
			lastSubtitle = subtitleText
			subtitleCharactersRemainingLabel.text = "(\(difference))"
		}
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		textView.layer.borderWidth = 2
		textView.layer.borderColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
		if textView == tagsTextView && hasTagsPlaceholder {
			hasTagsPlaceholder = false
			tagsTextView.text = ""
			tagsTextView.textColor = .darkGray
			tagsTextView.font = UIFont(name: "Nunito-SemiBold", size: 17)
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		textView.layer.borderWidth = 1
		textView.layer.borderColor = UIColor.lightGray.cgColor
		if textView == tagsTextView && tagsTextView.text.isEmpty {
			hasTagsPlaceholder = true
			tagsTextView.text = "Separate with commas"
			tagsTextView.textColor = .lightGray
			tagsTextView.font = UIFont(name: "Nunito-Regular", size: 17)
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if textView == tagsTextView {
			let difference = TAGS_COUNT - getTags().count
			if difference < 0 {
				tagsTextView.text = lastTags
			} else {
				lastTags = tagsTextView.text
				tagsRemainingLabel.text = "(\(difference))"
			}
		}
	}
	
	func getTags() -> [String] {
		return tagsTextView.text.split(separator: ",").map { String($0).trim() }.filter { !$0.isEmpty }
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
		guard let id = id, let image = imageView.image?.compressedData(), let nameText = nameTextField.text?.trim(), let subtitleText = subtitleTextField.text?.trim() else { return }
		let date = Date()
		showActivityIndicator()
		dismissKeyboard()
		let metadata = StorageMetadata()
		metadata.contentType = "image/jpeg"
		var deckRef: DocumentReference?
		deckRef = firestore.collection("decks").addDocument(data: [
			"name": nameText,
			"subtitle": subtitleText,
			"description": descriptionTextView.text.trim(),
			"tags": getTags(),
			"public": isPublic,
			"count": 0,
			"views": ["total": 0, "unique": 0],
			"downloads": ["total": 0, "current": 0],
			"ratings": ["average": 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0],
			"creator": id,
			"owner": id,
			"created": date,
			"updated": date
		]) { error in
			guard error == nil, let deckId = deckRef?.documentID else { return }
			firestore.document("users/\(id)/decks/\(deckId)").setData(["mastered": 0])
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
		createButton.setTitleColor(#colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1), for: .normal)
		createButton.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
	}
	
	func disable() {
		createButton.isEnabled = false
		createButton.setTitleColor(#colorLiteral(red: 0.8264711499, green: 0.8266105652, blue: 0.8264527917, alpha: 1), for: .normal)
		createButton.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

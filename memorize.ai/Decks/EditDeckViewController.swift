import UIKit
import Firebase

class EditDeckViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var outerImageView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var changeButton: UIButton!
	@IBOutlet weak var nameBlockView: UIView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameBarView: UIView!
	@IBOutlet weak var subtitleCharactersRemainingLabel: UILabel!
	@IBOutlet weak var subtitleBlockView: UIView!
	@IBOutlet weak var subtitleTextField: UITextField!
	@IBOutlet weak var subtitleBarView: UIView!
	@IBOutlet weak var tagsRemainingLabel: UILabel!
	@IBOutlet weak var tagsTextView: UITextView!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var publicSwitch: UISwitch!
	@IBOutlet weak var privateSwitch: UISwitch!
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
	
	let SUBTITLE_LENGTH = 60
	let TAGS_COUNT = 20
	
	var deck: Deck?
	var hasTagsPlaceholder = true
	var lastTags = ""
	var lastSubtitle = ""
	
	override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.title = "\(deck == nil ? "New" : "Edit") Deck"
		loadText()
		loadBlocks()
		disable()
		imageView.layer.borderColor = UIColor.lightGray.cgColor
		submitButton.layer.borderColor = UIColor.lightGray.cgColor
		imageView.layer.masksToBounds = true
		nameTextField.setKeyboard()
		textViewDidEndEditing(tagsTextView)
		textViewDidEndEditing(descriptionTextView)
		tagsTextView.setKeyboard(.plain)
		descriptionTextView.setKeyboard(.advanced)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .deckModified {
				self.loadBlocks()
			}
		}
		updateCurrentViewController()
	}
	
	func loadText() {
		guard let deck = deck else { return }
		nameTextField.text = deck.name
		subtitleTextField.text = deck.subtitle
		tagsTextView.text = deck.tags.joined(separator: ", ")
		descriptionTextView.text = deck.description
		publicSwitch.setOn(deck.isPublic, animated: false)
		privateSwitch.setOn(!deck.isPublic, animated: false)
	}
	
	func loadBlocks() {
		guard let role = deck?.role else { return }
		switch role {
		case .owner, .admin:
			nameBlockView.isHidden = true
			subtitleBarView.isHidden = true
		default:
			nameBlockView.isHidden = false
			subtitleBlockView.isHidden = false
		}
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
		reloadSubmit()
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
		reloadSubmit()
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
		reloadSubmit()
	}
	
	func getTags() -> [String] {
		return hasTagsPlaceholder ? [] : tagsTextView.text.split(separator: ",").map { String($0).trim() }.filter { !$0.isEmpty }
	}
	
	@IBAction func publicSwitchChanged() {
		privateSwitch.setOn(!privateSwitch.isOn, animated: true)
		reloadSubmit()
	}
	
	@IBAction func privateSwitchChanged() {
		publicSwitch.setOn(!publicSwitch.isOn, animated: true)
		reloadSubmit()
	}
	
	@IBAction func submit() {
		guard let id = id, let imageData = imageView.image?.compressedData(), let nameText = nameTextField.text?.trim(), let subtitleText = subtitleTextField.text?.trim() else { return }
		showActivityIndicator()
		loadSubmitBarButtonItem(false)
		dismissKeyboard()
		if let deck = deck {
			firestore.document("decks/\(deck.id)").updateData([
				"name": nameText,
				"subtitle": subtitleText,
				"description": descriptionTextView.text.trim(),
				"tags": getTags(),
				"public": publicSwitch.isOn,
			]) { error in
				if error == nil {
					self.setImage(deck.id, data: imageData) {
						buzz()
						self.hideActivityIndicator()
					}
				} else {
					self.showAlert("Unable to publish changes. Please try again")
				}
			}
		} else {
			let date = Date()
			var deckRef: DocumentReference?
			deckRef = firestore.collection("decks").addDocument(data: [
				"name": nameText,
				"subtitle": subtitleText,
				"description": descriptionTextView.text.trim(),
				"tags": getTags(),
				"public": publicSwitch.isOn,
				"count": 0,
				"views": ["total": 0, "unique": 0],
				"downloads": ["total": 0, "current": 0],
				"ratings": ["average": 0, "1": 0, "2": 0, "3": 0, "4": 0, "5": 0],
				"creator": id,
				"owner": id,
				"created": date,
				"updated": date
			]) { error in
				if error == nil, let deckId = deckRef?.documentID {
					Deck.new(deckId) { error in
						if error == nil {
							self.setImage(deckId, data: imageData) {
								self.navigationController?.popViewController(animated: true)
							}
						} else {
							self.showAlert("Unable to add the deck to your library. You can manually get the deck from the Marketplace")
							self.navigationController?.popViewController(animated: true)
						}
					}
				} else {
					self.hideActivityIndicator()
					self.enable()
				}
			}
		}
	}
	
	func setImage(_ deckId: String, data: Data, completion: @escaping () -> Void) {
		storage.child("decks/\(deckId)").putData(data, metadata: JPEG_METADATA) { _, error in
			if let error = error {
				self.hideActivityIndicator()
				switch error.localizedDescription {
				case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
					self.showAlert("No internet")
				default:
					self.showAlert("There was a problem creating a new deck")
				}
			} else {
				self.hideActivityIndicator()
				completion()
			}
		}
	}
	
	@objc func submitFromBarButton() {
		scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height), animated: true)
		submit()
	}
	
	func reloadSubmit() {
		guard let nameText = nameTextField.text?.trim(), let subtitleText = subtitleTextField.text?.trim() else { return }
		if nameText.isEmpty {
			disable()
		} else if let deck = deck, deck.name == nameText && deck.subtitle == subtitleText && deck.tags == getTags() && deck.description == descriptionTextView.text && deck.isPublic == publicSwitch.isOn {
				disable()
		} else {
			enable()
		}
	}
	
	func loadSubmitBarButtonItem(_ enabled: Bool) {
		navigationItem.setRightBarButton(UIBarButtonItem(title: deck == nil ? "Create" : "Publish", style: .done, target: self, action: #selector(submitFromBarButton)), animated: false)
		guard let rightBarButton = navigationItem.rightBarButtonItem else { return }
		rightBarButton.isEnabled = enabled
		rightBarButton.tintColor = enabled ? .white : #colorLiteral(red: 0.9841352105, green: 0.9841352105, blue: 0.9841352105, alpha: 1)
	}
	
	func showActivityIndicator() {
		submitButton.isEnabled = false
		submitButton.setTitle(nil, for: .normal)
		submitActivityIndicator.startAnimating()
	}
	
	func hideActivityIndicator() {
		submitButton.isEnabled = true
		submitButton.setTitle(deck == nil ? "CREATE" : "PUBLISH", for: .normal)
		submitActivityIndicator.stopAnimating()
	}
	
	func enable() {
		submitButton.isEnabled = true
		submitButton.setTitleColor(#colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1), for: .normal)
		submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
		loadSubmitBarButtonItem(true)
	}
	
	func disable() {
		submitButton.isEnabled = false
		submitButton.setTitleColor(#colorLiteral(red: 0.8264711499, green: 0.8266105652, blue: 0.8264527917, alpha: 1), for: .normal)
		submitButton.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)
		loadSubmitBarButtonItem(false)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

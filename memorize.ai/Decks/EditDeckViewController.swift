import UIKit
import Firebase

class EditDeckViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var outerImageView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var changeButton: UIButton!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
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
	@IBOutlet weak var publicBlockView: UIView!
	@IBOutlet weak var privateSwitch: UISwitch!
	@IBOutlet weak var privateBlockView: UIView!
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
	
	let SUBTITLE_LENGTH = 60
	let TAGS_COUNT = 20
	
	var didChangeImage = false
	var image: UIImage?
	var deck: Deck?
	var hasTagsPlaceholder = true
	var lastTags = ""
	var lastSubtitle = ""
	
	deinit {
		KeyboardHandler.removeListener(self)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.title = "\(deck == nil ? "New" : "Edit") Deck"
		submitButton.setTitle(deck == nil ? "CREATE" : "PUBLISH", for: .normal)
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
		KeyboardHandler.addListener(self, up: keyboardWillShow, down: keyboardWillHide)
		updateCurrentViewController()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		if let uploadsVC = segue.destination as? UploadsViewController, sender as? Bool ?? false {
			uploadsVC.audioAllowed = false
			uploadsVC.completion = { upload in
				if upload.type == .audio {
					self.showNotification("Upload must be an image or gif", type: .error)
					return
				}
				if let image = upload.image {
					self.didChangeImage = true
					self.image = image
					self.imageView.image = image
					self.reloadSubmit()
				} else {
					self.imageView.image = nil
					self.changeButton.isEnabled = false
					self.imageActivityIndicator.startAnimating()
					upload.load { _, error in
						self.changeButton.isEnabled = true
						self.imageActivityIndicator.stopAnimating()
						if error == nil, let image = upload.image {
							self.image = image
							self.reloadSubmit()
						} else {
							self.showNotification("Unable to load image. Please try again", type: .error)
						}
						self.imageView.image = self.image ?? DEFAULT_DECK_IMAGE
					}
				}
			}
		}
	}
	
	func keyboardWillShow() {
		scrollViewBottomConstraint.constant = keyboardOffset - bottomSafeAreaInset
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func keyboardWillHide() {
		scrollViewBottomConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func loadText() {
		guard let deck = deck else { return }
		image = deck.image
		imageView.image = image ?? DEFAULT_DECK_IMAGE
		nameTextField.text = deck.name
		subtitleTextField.text = deck.subtitle
		let tags = deck.tags.joined(separator: ", ")
		tagsTextView.text = tags
		hasTagsPlaceholder = tags.isEmpty
		if !hasTagsPlaceholder {
			tagsTextView.textColor = .darkGray
			tagsTextView.font = UIFont(name: "Nunito-SemiBold", size: 17)
		}
		descriptionTextView.text = deck.description
		publicSwitch.setOn(deck.isPublic, animated: false)
		privateSwitch.setOn(!deck.isPublic, animated: false)
		subtitleChanged()
		textViewDidChange(tagsTextView)
	}
	
	func loadBlocks() {
		guard let role = deck?.role else { return }
		if role == .editor {
			changeButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
			changeButton.isEnabled = false
			nameBlockView.isHidden = false
			subtitleBlockView.isHidden = false
			publicBlockView.isHidden = false
			privateBlockView.isHidden = false
		}
	}
	
	@IBAction
	func chooseImage() {
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
		alert.addAction(UIAlertAction(title: "Your Uploads", style: .default) { _ in
			self.performSegue(withIdentifier: "uploads", sender: true)
		})
		if image != nil {
			alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
				self.didChangeImage = true
				self.image = nil
				self.imageView.image = DEFAULT_DECK_IMAGE
				self.reloadSubmit()
			})
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.popoverPresentationController?.sourceView = view
		present(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			didChangeImage = true
			self.image = image
			imageView.image = image
			reloadSubmit()
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
			barView?.backgroundColor = DEFAULT_BLUE_COLOR
		}, completion: nil)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		let barView = textField == nameTextField ? nameBarView : subtitleBarView
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			barView?.transform = .identity
			barView?.backgroundColor = .lightGray
		}, completion: nil)
	}
	
	@IBAction
	func nameChanged() {
		reloadSubmit()
	}
	
	@IBAction
	func subtitleChanged() {
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
		textView.layer.borderColor = DEFAULT_BLUE_COLOR.cgColor
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
	
	@IBAction
	func publicSwitchChanged() {
		privateSwitch.setOn(!privateSwitch.isOn, animated: true)
		reloadSubmit()
	}
	
	@IBAction
	func privateSwitchChanged() {
		publicSwitch.setOn(!publicSwitch.isOn, animated: true)
		reloadSubmit()
	}
	
	@IBAction
	func submit() {
		guard let id = id, let nameText = nameTextField.text?.trim(), let subtitleText = subtitleTextField.text?.trim() else { return }
		showActivityIndicator()
		loadSubmitBarButtonItem(false)
		dismissKeyboard()
		if let deck = deck {
			let description = descriptionTextView.text.trim()
			let tags = getTags()
			firestore.document("decks/\(deck.id)").updateData(deck.role == .editor ? [
				"description": description,
				"tags": tags,
			] : [
				"hasImage": image == nil ? FieldValue.delete() : true,
				"name": nameText,
				"subtitle": subtitleText,
				"description": description,
				"tags": tags,
				"public": publicSwitch.isOn
			]) { error in
				if error == nil {
					if deck.role == .editor || !self.didChangeImage {
						buzz()
						self.hideActivityIndicator()
						self.disable()
					} else if let image = self.image?.fixedRotation {
						if let imageData = image.compressedData {
							self.setImage(deck.id, data: imageData) {
								deck.image = image
								Deck.cache(deck.id, image: image)
								buzz()
								self.hideActivityIndicator()
								self.disable()
							}
						} else {
							self.hideActivityIndicator()
							self.enable()
							self.showNotification("Unable to change image. Please try again", type: .error)
						}
					} else {
						storage.child("decks/\(deck.id)").delete { error in
							if error == nil {
								deck.image = nil
								Deck.cache(deck.id, image: nil)
								buzz()
								self.hideActivityIndicator()
								self.disable()
							} else {
								self.hideActivityIndicator()
								self.enable()
								self.showNotification("Unable to reset image. Please try again", type: .error)
							}
						}
					}
				} else {
					self.hideActivityIndicator()
					self.enable()
					self.showNotification("Unable to publish changes. Please try again", type: .error)
				}
			}
		} else {
			let date = Date()
			var data: [String : Any] = [
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
			]
			if image != nil {
				data["hasImage"] = true
			}
			var deckRef: DocumentReference?
			deckRef = firestore.collection("decks").addDocument(data: data) { error in
				if error == nil, let deckId = deckRef?.documentID {
					Deck.view(deckId) { error in
						if error == nil {
							Deck.new(deckId) { error in
								if error == nil, let image = self.image?.fixedRotation, let imageData = image.compressedData {
									self.setImage(deckId, data: imageData) {
										Deck.cache(deckId, image: image)
										self.navigationController?.popViewController(animated: true)
									}
								} else {
									Deck.cache(deckId, image: nil)
									self.navigationController?.popViewController(animated: true)
								}
							}
						} else {
							self.hideActivityIndicator()
							self.enable()
							self.showNotification("Unable to create deck. Please try again", type: .error)
						}
					}
				} else {
					self.hideActivityIndicator()
					self.enable()
					self.showNotification("Unable to create deck. Please try again", type: .error)
				}
			}
		}
	}
	
	func setImage(_ deckId: String, data: Data, completion: @escaping () -> Void) {
		storage.child("decks/\(deckId)").putData(data, metadata: JPEG_METADATA) { _, error in
			self.hideActivityIndicator()
			switch error?.localizedDescription {
			case .none:
				completion()
			case .some("Network error (such as timeout, interrupted connection or unreachable host) has occurred."):
				self.showNotification("No internet", type: .error)
			default:
				self.showNotification("There was a problem creating a new deck", type: .error)
			}
		}
	}
	
	@objc
	func submitFromBarButton() {
		scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height), animated: true)
		submit()
	}
	
	func reloadSubmit() {
		guard let nameText = nameTextField.text?.trim(), let subtitleText = subtitleTextField.text?.trim() else { return }
		if nameText.isEmpty {
			disable()
		} else if let deck = deck, deck.image == imageView.image && deck.name == nameText && deck.subtitle == subtitleText && deck.tags == getTags() && deck.description == descriptionTextView.text && deck.isPublic == publicSwitch.isOn {
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
		submitButton.backgroundColor = DEFAULT_BLUE_COLOR
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

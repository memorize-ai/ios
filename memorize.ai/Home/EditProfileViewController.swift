import UIKit
import SafariServices
import MessageUI

class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var editBackgroundImageView: UIImageView!
	@IBOutlet weak var editBackgroundImageButton: UIButton!
	@IBOutlet weak var editBackgroundImageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var profilePictureImageView: UIImageView!
	@IBOutlet weak var editProfilePictureImageView: UIImageView!
	@IBOutlet weak var editProfilePictureButton: UIButton!
	@IBOutlet weak var editProfilePictureActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var bioLabel: UILabel!
	@IBOutlet weak var bioLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var bioMoreLabel: UILabel!
	@IBOutlet weak var showFullBioButton: UIButton!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var optionsTableView: UITableView!
	@IBOutlet weak var optionsTableViewHeightConstraint: NSLayoutConstraint!
	
	class Option {
		let image: UIImage
		let name: String
		let action: (EditProfileViewController) -> () -> Void
		
		init(image: UIImage, name: String, action: @escaping (EditProfileViewController) -> () -> Void) {
			self.image = image
			self.name = name
			self.action = action
		}
	}
	
	let options = [
		Option(image: #imageLiteral(resourceName: "Settings"), name: "Settings", action: showSettings),
		Option(image: #imageLiteral(resourceName: "Cloud"), name: "Uploads", action: showUploads),
		Option(image: #imageLiteral(resourceName: "Decks"), name: "Deck Ratings", action: showDeckRatings),
		Option(image: #imageLiteral(resourceName: "Cards"), name: "Card Ratings", action: showCardRatings),
		Option(image: #imageLiteral(resourceName: "Smiling Emoji"), name: "Emoji Game", action: showEmojiGame),
		Option(image: #imageLiteral(resourceName: "Book"), name: "Tutorial", action: showTutorial)
	] + (MFMailComposeViewController.canSendMail() ? [Option(image: #imageLiteral(resourceName: "Mail"), name: "Contact Us", action: showContactUsEmail)] : [])
	var currentImageEditing: User.ImageType?
	var isBioExpanded = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let settingsButton = UIButton(type: .custom)
		settingsButton.setImage(#imageLiteral(resourceName: "Settings White"), for: .normal)
		settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
		settingsButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
		settingsButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
		navigationItem.setRightBarButton(UIBarButtonItem(customView: settingsButton), animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.profileModified, .settingAdded) { change in
			if change == .profileModified || change == .profilePicture {
				self.load()
			}
		}
		resizeOptionsTableView()
		updateCurrentViewController()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		if let uploadsVC = segue.destination as? UploadsViewController, sender as? Bool ?? false, let currentImageEditing = currentImageEditing {
			uploadsVC.audioAllowed = false
			uploadsVC.completion = { upload in
				if upload.type == .audio { return self.showNotification("Upload must be an image or gif", type: .error) }
				self.handleUpload(upload, type: currentImageEditing)
			}
		}
	}
	
	@IBAction
	func changeBackgroundImage() {
		if backgroundImage == nil { return chooseImage(.backgroundImage) }
		chooseImage(.backgroundImage) {
			self.setBackgroundImageView(nil)
			self.setLoading(.backgroundImage, loading: true)
			self.uploadImage(nil, type: .backgroundImage) { success, shouldShowNotification in
				self.setLoading(.backgroundImage, loading: false)
				if success {
					self.showNotification("Reset background image", type: .success)
				} else {
					self.setBackgroundImageView(backgroundImage)
					if shouldShowNotification {
						self.showNotification("Unable to reset background image. Please try again", type: .error)
					}
				}
			}
		}
	}
	
	@IBAction
	func changeProfilePicture() {
		if profilePicture == nil { return chooseImage(.profilePicture) }
		chooseImage(.profilePicture) {
			self.setProfilePictureImageView(DEFAULT_PROFILE_PICTURE)
			self.setLoading(.profilePicture, loading: true)
			self.uploadImage(nil, type: .profilePicture) { success, shouldShowNotification in
				self.setLoading(.profilePicture, loading: false)
				if success {
					self.showNotification("Reset profile picture", type: .success)
				} else {
					self.setProfilePictureImageView(profilePicture ?? DEFAULT_PROFILE_PICTURE)
					if shouldShowNotification {
						self.showNotification("Unable to reset profile picture. Please try again", type: .error)
					}
				}
			}
		}
	}
	
	@IBAction
	func changeName() {
		let alertController = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
		alertController.addTextField {
			$0.placeholder = "Name"
			$0.text = name
			$0.clearButtonMode = .whileEditing
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Change", style: .default) { _ in
			let newName = alertController.textFields?.first?.text?.trim() ?? ""
			if newName.isEmpty { return self.showNotification("Name cannot be blank", type: .error) }
			if newName == name { return self.showNotification("Please choose a different name", type: .error) }
			guard let id = id else { return }
			firestore.document("users/\(id)").updateData(["name": newName]) { error in
				self.showNotification(error == nil ? "Changed name" : "Unable to change name. Please try again", type: error == nil ? .success : .error)
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction
	func changeBio() {
		performSegue(withIdentifier: "editBio", sender: self)
	}
	
	@IBAction
	func changeEmail() {
		let alertController = UIAlertController(title: "Change email", message: nil, preferredStyle: .alert)
		alertController.addTextField {
			$0.placeholder = "Email"
			$0.text = email
			$0.keyboardType = .emailAddress
			$0.clearButtonMode = .whileEditing
		}
		alertController.addTextField {
			$0.placeholder = "Confirm password"
			$0.isSecureTextEntry = true
			$0.clearButtonMode = .whileEditing
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Change", style: .default) { _ in
			guard let email = email, let id = id else { return }
			let newEmail = alertController.textFields?.first?.text?.trim() ?? ""
			if newEmail.isEmpty { return self.showNotification("Email cannot be blank", type: .error) }
			let password = alertController.textFields?.last?.text?.trim() ?? ""
			if password.isEmpty { return self.showNotification("Password cannot be blank", type: .error) }
			self.showNotification("Changing email...", type: .normal)
			auth.signIn(withEmail: email, password: password) { _, error in
				guard error == nil else { return self.showNotification("Invalid password", type: .error) }
				guard newEmail.isValidEmail else { return self.showNotification("Invalid email", type: .error) }
				firestore.collection("users").whereField("email", isEqualTo: newEmail).getDocuments { snapshot, error in
					guard error == nil, let snapshot = snapshot?.documents, let currentUser = auth.currentUser else { return self.showNotification("Unable to validate email. Please try again", type: .error) }
					guard snapshot.isEmpty else { return self.showNotification("Email is already in use", type: .error) }
					currentUser.updateEmail(to: newEmail) { error in
						guard error == nil else { return self.showNotification("Unable to change email. Please try again", type: .error) }
						firestore.document("users/\(id)").updateData(["email": newEmail]) { error in
							self.showNotification(error == nil ? "Changed email" : "Unable to change email. Please try again", type: error == nil ? .success : .error)
						}
					}
				}
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction
	func resetPassword() {
		guard let email = email else { return }
		let alertController = UIAlertController(title: "Reset password", message: "Send a password reset email to \(email)", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Send", style: .default) { _ in
			auth.sendPasswordReset(withEmail: email) { error in
				self.showNotification(error == nil ? "Sent. Check your email to reset your password" : "Unable to send password reset email. Please try again", type: error == nil ? .success : .error)
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction
	func share() {
		getProfileLink { url in
			guard let url = url else { return self.showNotification("Unable to share. Please try again", type: .error) }
			let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
			activityVC.popoverPresentationController?.sourceView = self.view
			self.present(activityVC, animated: true, completion: nil)
		}
	}
	
	func getProfileLink(completion: @escaping (URL?) -> Void) {
		if let id = id, let name = name, let slug = slug {
			User.getDynamicLink(id: id, name: name, slug: slug, completion: completion)
		} else {
			showNotification("Loading profile link...", type: .normal)
		}
	}
	
	@IBAction
	func viewProfile() {
		performSegue(withIdentifier: "viewProfile", sender: self)
	}
	
	@IBAction
	func showFullBio() {
		showFullBioButton.isEnabled = false
		isBioExpanded = true
		setBio()
	}
	
	func load() {
		setBackgroundImageView(backgroundImage)
		setProfilePictureImageView(profilePicture ?? DEFAULT_PROFILE_PICTURE)
		nameLabel.text = name
		setBio()
		emailLabel.text = email
	}
	
	func setBio() {
		guard let bio = bio else { return }
		if bio.isEmpty {
			bioLabel.text = "(no bio)"
			bioLabel.textColor = .darkGray
		} else {
			bioLabel.text = bio
			bioLabel.textColor = .black
		}
		if isBioExpanded {
			bioMoreLabel.isHidden = true
			bioLabelHeightConstraint?.isActive = false
			view.layoutIfNeeded()
		} else {
			bioMoreLabel.isHidden = !bioLabel.isTruncated
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let currentImageEditing = currentImageEditing, let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			switch currentImageEditing {
			case .profilePicture:
				setProfilePictureImageView(image)
			case .backgroundImage:
				setBackgroundImageView(image)
			}
			setLoading(currentImageEditing, loading: true)
			uploadImage(image, type: currentImageEditing) { success, shouldShowNotification in
				self.setLoading(currentImageEditing, loading: false)
				switch currentImageEditing {
				case .profilePicture:
					if success {
						self.showNotification("Updated profile picture", type: .success)
					} else {
						self.setProfilePictureImageView(profilePicture ?? DEFAULT_PROFILE_PICTURE)
						if shouldShowNotification {
							self.showNotification("Unable to set profile picture. Please try again", type: .error)
						}
					}
				case .backgroundImage:
					if success {
						self.showNotification("Updated background image", type: .success)
					} else {
						self.setBackgroundImageView(backgroundImage)
						if shouldShowNotification {
							self.showNotification("Unable to set background image. Please try again", type: .error)
						}
					}
				}
			}
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	func chooseImage(_ type: User.ImageType, resetHandler: (() -> Void)? = nil) {
		currentImageEditing = type
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
		if let resetHandler = resetHandler {
			alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
				resetHandler()
			})
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.popoverPresentationController?.sourceView = view
		present(alert, animated: true, completion: nil)
	}
	
	func setLoading(_ type: User.ImageType, loading: Bool) {
		switch type {
		case .profilePicture:
			editProfilePictureButton.isEnabled = !loading
			editProfilePictureImageView.isHidden = loading
			editProfilePictureActivityIndicator.setAnimating(loading)
		case .backgroundImage:
			editBackgroundImageButton.isEnabled = !loading
			editBackgroundImageView.isHidden = loading
			editBackgroundImageActivityIndicator.setAnimating(loading)
		}
	}
	
	func uploadImage(_ image: UIImage?, type: User.ImageType, completion: @escaping (Bool, Bool) -> Void) {
		guard let id = id else { return completion(false, true) }
		if let image = image?.fixedRotation {
			guard let data = image.compressedData else { return completion(false, true) }
			if data.count > MAX_FILE_SIZE {
				showNotification("Image exceeds 50 MB. Please choose another image", type: .error)
				completion(false, false)
				return
			}
			storage.child("users/\(id)/\(type.rawValue)").putData(data, metadata: JPEG_METADATA) { _, error in
				guard error == nil else { return completion(false, true) }
				switch type {
				case .profilePicture:
					storage.child("users/\(id)/profile").downloadURL { url, error in
						guard error == nil, let url = url, let changeRequest = auth.currentUser?.createProfileChangeRequest() else { return completion(false, true) }
						changeRequest.photoURL = url
						changeRequest.commitChanges { error in
							guard error == nil else { return completion(false, true) }
							profilePicture = image
							User.save(profilePicture: data)
							User.cache(id, image: image, type: .profilePicture)
							completion(true, true)
						}
					}
				case .backgroundImage:
					backgroundImage = image
					User.save(backgroundImage: data)
					User.cache(id, image: image, type: .backgroundImage)
					completion(true, true)
				}
			}
		} else {
			storage.child("users/\(id)/\(type.rawValue)").delete { error in
				guard error == nil else { return completion(false, true) }
				switch type {
				case .profilePicture:
					profilePicture = nil
					User.save(profilePicture: nil)
					User.cache(id, image: nil, type: .profilePicture)
				case .backgroundImage:
					backgroundImage = nil
					User.save(backgroundImage: nil)
					User.cache(id, image: nil, type: .backgroundImage)
				}
				completion(true, true)
			}
		}
	}
	
	func handleUpload(_ upload: Upload, type imageType: User.ImageType) {
		let errorMessage = "Unable to set \(imageType.description). Please try again"
		func setImage(_ image: UIImage?) {
			switch imageType {
			case .profilePicture:
				setProfilePictureImageView(image)
			case .backgroundImage:
				setBackgroundImageView(image)
			}
		}
		func uploadImage(_ image: UIImage) {
			self.uploadImage(image, type: imageType) { success, shouldShowNotification in
				self.setLoading(imageType, loading: false)
				if success {
					self.showNotification("Updated \(imageType.description)", type: .success)
				} else {
					switch imageType {
					case .profilePicture:
						self.setProfilePictureImageView(profilePicture ?? DEFAULT_PROFILE_PICTURE)
					case .backgroundImage:
						self.setBackgroundImageView(backgroundImage)
					}
					if shouldShowNotification {
						self.showNotification(errorMessage, type: .error)
					}
				}
			}
		}
		self.setLoading(imageType, loading: true)
		let image = upload.image
		setImage(image)
		if let image = image {
			uploadImage(image)
		} else {
			upload.load { _, error in
				if error == nil, let image = upload.image {
					setImage(image)
					uploadImage(image)
				} else {
					self.showNotification(errorMessage, type: .error)
				}
			}
		}
	}
	
	func setProfilePictureImageView(_ image: UIImage?) {
		profilePictureImageView.image = image
		let isImageNil = image == nil
		profilePictureImageView.layer.borderWidth = isImageNil ? 0.5 : 0
		profilePictureImageView.layer.borderColor = isImageNil ? UIColor.lightGray.cgColor : nil
	}
	
	func setBackgroundImageView(_ image: UIImage?) {
		backgroundImageView.image = image
		backgroundImageView.backgroundColor = image == nil ? DEFAULT_BACKGROUND_IMAGE_COLOR : .white
	}
	
	func resizeOptionsTableView() {
		optionsTableViewHeightConstraint.constant = CGFloat(56 * options.count)
		view.layoutIfNeeded()
	}
	
	@objc
	func showSettings() {
		performSegue(withIdentifier: "settings", sender: self)
	}
	
	func showUploads() {
		performSegue(withIdentifier: "uploads", sender: false)
	}
	
	func showDeckRatings() {
		performSegue(withIdentifier: "deckRatings", sender: self)
	}
	
	func showCardRatings() {
		performSegue(withIdentifier: "cardRatings", sender: self)
	}
	
	func showEmojiGame() {
		performSegue(withIdentifier: "emojiGame", sender: self)
	}
	
	func showTutorial() {
		performSegue(withIdentifier: "tutorial", sender: self)
	}
	
	func showContactUsEmail() {
		guard MFMailComposeViewController.canSendMail() else { return showNotification("You must add an email account to this device in settings before you can send mail", type: .error) }
		guard let id = id, let name = name, let email = email, let slug = slug else { return showNotification("Unable to load your profile link. Please try again", type: .error) }
		getProfileLink { url in
			guard let url = url?.absoluteString else { return self.showNotification("Unable to load your profile link. Please try again", type: .error) }
			let mailComposeVC = MFMailComposeViewController()
			mailComposeVC.delegate = self
			mailComposeVC.setToRecipients([MEMORIZE_AI_SUPPORT_EMAIL])
			mailComposeVC.setMessageBody("""
			\n\n=== User info ===
			ID: \(id)
			Name: \(name)
			Email: \(email)
			Profile link: <a href="\(url)">memorize.ai/\(User.urlString(slug: slug))</a>
			iOS App version: \(APP_VERSION ?? "1.0")
			iOS version: \(UIDevice.current.systemVersion)
			Device: \(CURRENT_DEVICE.description)
			""", isHTML: true)
			self.present(mailComposeVC, animated: true, completion: nil)
		}
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction
	func signOut() {
		let alertController = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
			if (try? auth.signOut()) == nil { return self.showNotification("Unable to sign out. Please try again", type: .error) }
			Listener.removeAll()
			uploads.removeAll()
			invites.removeAll()
			settings.removeAll()
			sectionedSettings.removeAll()
			cardDrafts.removeAll()
			ratingDrafts.removeAll()
			deckRatings.removeAll()
			cardRatings.removeAll()
			allDecks.removeAll()
			User.delete()
			self.performSegue(withIdentifier: "signOut", sender: self)
		})
		present(alertController, animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return options.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? OptionTableViewCell else { return _cell }
		let element = options[indexPath.row]
		cell.optionImageView.image = element.image
		cell.nameLabel.text = element.name
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		options[indexPath.row].action(self)()
	}
}

class OptionTableViewCell: UITableViewCell {
	@IBOutlet weak var optionImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
}

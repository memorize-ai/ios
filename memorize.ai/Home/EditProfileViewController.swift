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
	@IBOutlet weak var profileLinkLabel: UILabel!
	@IBOutlet weak var profileLinkTextLabel: UILabel!
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share)), animated: true)
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
		if let uploadsVC = segue.destination as? UploadsViewController, sender as? Bool ?? false {
			uploadsVC.audioAllowed = false
			uploadsVC.completion = { upload in
				if upload.type == .audio { return self.showNotification("Upload must be an image or gif", type: .error) }
				self.setLoading(true)
				if let image = upload.image {
					self.uploadImage(image) { success in
						self.setLoading(false)
						if success {
							profilePicture = image
						} else {
							self.showNotification("Unable to set profile picture. Please try again", type: .error)
						}
						self.pictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
					}
				} else {
					upload.load { _, error in
						self.setLoading(false)
						if error == nil, let image = upload.image {
							profilePicture = image
						} else {
							self.showNotification("Unable to set profile picture. Please try again", type: .error)
						}
						self.pictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
					}
				}
			}
		}
	}
	
	@IBAction
	func changeBackgroundImage() {
		chooseImage(.backgroundImage) {
			
		}
	}
	
	@IBAction
	func changeProfilePicture() {
		
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
	
	@objc
	func share() {
		if let slug = slug, let url = User.url(slug: slug) {
			let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
			activityVC.popoverPresentationController?.sourceView = view
			present(activityVC, animated: true, completion: nil)
		} else {
			showNotification("Loading profile url...", type: .normal)
		}
	}
	
	func load() {
		backgroundImageView.image = backgroundImage
		backgroundImageView.backgroundColor = backgroundImage == nil ? .lightGray : .white
		profilePictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
		nameLabel.text = name
		bioLabel.text = bio
		emailLabel.text = email
		profileLinkLabel.text = "PROFILE LINK\(slug == nil ? " (LOADING)" : "")"
		profileLinkTextLabel.text = User.urlString(slug: slug ?? "...")
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let currentImageEditing = currentImageEditing, let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			switch currentImageEditing {
			case .profilePicture:
				profilePictureImageView.image = image
			case .backgroundImage:
				backgroundImageView.image = image
			}
			setLoading(currentImageEditing, loading: true)
			uploadImage(image, type: currentImageEditing) { success in
				self.setLoading(currentImageEditing, loading: false)
				switch currentImageEditing {
				case .profilePicture:
					if success {
						self.showNotification("Updated profile picture", type: .success)
					} else {
						self.profilePictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
						self.showNotification("Unable to set profile picture. Please try again", type: .error)
					}
				case .backgroundImage:
					if success {
						self.showNotification("Updated background image", type: .success)
					} else {
						self.backgroundImageView.image = backgroundImage
						self.backgroundImageView.backgroundColor = backgroundImage == nil ? .lightGray : .white
						self.showNotification("Unable to set background image. Please try again", type: .error)
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
	
	func uploadImage(_ image: UIImage?, type: User.ImageType, completion: @escaping (Bool) -> Void) {
		guard let id = id else { return completion(false) }
		if let image = image?.fixedRotation {
			guard let data = image.compressedData else { return completion(false) }
			storage.child("users/\(id)/\(type.rawValue)").putData(data, metadata: JPEG_METADATA) { _, error in
				guard error == nil else { return completion(false) }
				switch type {
				case .profilePicture:
					storage.child("users/\(id)/profile").downloadURL { url, error in
						guard error == nil, let url = url, let changeRequest = auth.currentUser?.createProfileChangeRequest() else { return completion(false) }
						changeRequest.photoURL = url
						changeRequest.commitChanges { error in
							guard error == nil else { return completion(false) }
							profilePicture = image
							User.save(profilePicture: data)
							User.cache(id, image: image, type: .profilePicture)
							completion(true)
						}
					}
				case .backgroundImage:
					backgroundImage = image
					User.save(backgroundImage: data)
					User.cache(id, image: image, type: .backgroundImage)
					completion(true)
				}
			}
		} else {
			storage.child("users/\(id)/\(type.rawValue)").delete { error in
				guard error == nil else { return completion(false) }
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
				completion(true)
			}
		}
	}
	
	func resizeOptionsTableView() {
		optionsTableViewHeightConstraint.constant = CGFloat(56 * options.count)
		view.layoutIfNeeded()
	}
	
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
		guard let id = id, let name = name, let email = email else { return }
		let profileLink = slug == nil ? nil : User.url(slug: slug ?? "...")?.absoluteString
		let mailComposeVC = MFMailComposeViewController()
		mailComposeVC.delegate = self
		mailComposeVC.setToRecipients([MEMORIZE_AI_SUPPORT_EMAIL])
		mailComposeVC.setMessageBody("""
		\n\n=== User info ===
		ID: \(id)
		Name: \(name)
		Email: \(email)\(profileLink == nil ? "" : "\nProfile link: \(profileLink ?? "unknown")")
		iOS App version: \(APP_VERSION ?? "1.0")
		iOS version: \(UIDevice.current.systemVersion)
		Device: \(CURRENT_DEVICE.description)
		""", isHTML: false)
		present(mailComposeVC, animated: true, completion: nil)
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

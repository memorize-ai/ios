import UIKit
import SafariServices
import MessageUI

class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
	@IBOutlet weak var pictureView: UIView!
	@IBOutlet weak var pictureImageView: UIImageView!
	@IBOutlet weak var changeButton: UIButton!
	@IBOutlet weak var pictureActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var linkLabel: UILabel!
	@IBOutlet weak var linkButton: UIButton!
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
		Option(image: #imageLiteral(resourceName: "Rating 4"), name: "Emoji Game", action: showEmojiGame), // Change image
		Option(image: #imageLiteral(resourceName: "Book"), name: "Tutorial", action: showTutorial)
	] + (MFMailComposeViewController.canSendMail() ? [Option(image: #imageLiteral(resourceName: "Mail"), name: "Contact Us", action: showContactUsEmail)] : [])
	
	override func viewDidLoad() {
		super.viewDidLoad()
		pictureImageView.layer.borderWidth = 0.5
		pictureImageView.layer.borderColor = UIColor.lightGray.cgColor
		pictureImageView.layer.masksToBounds = true
		navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share)), animated: false)
		if User.shouldShowEditProfileTip {
			User.shouldShowEditProfileTip = false
			showNotification("You can click on your profile picture, name, or email to change it", type: .normal, delay: 4)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.profileModified, .settingAdded) { change in
			if change == .profileModified || change == .profilePicture {
				self.nameLabel.text = name
				self.emailLabel.text = email
				if let slug = slug {
					self.linkLabel.text = "PROFILE LINK"
					self.linkButton.setTitle(User.urlString(slug: slug), for: .normal)
					self.linkButton.isEnabled = true
				} else {
					self.linkLabel.text = "PROFILE LINK (LOADING)"
					self.linkButton.setTitle(User.urlString(slug: "..."), for: .normal)
					self.linkButton.isEnabled = false
				}
				self.pictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
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
				if upload.type == .audio {
					self.showNotification("Upload must be an image or gif", type: .error)
					return
				}
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
		
		
		=== User info ===
		ID: \(id)
		Name: \(name)
		Email: \(email)\(profileLink == nil ? "" : "\nProfile link: \(profileLink ?? "unknown")")
		iOS App version: \(APP_VERSION ?? "1.0")
		iOS version: \(UIDevice.current.systemVersion)
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
		if profilePicture != nil {
			alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
				self.setLoading(true)
				self.uploadImage(nil) { success in
					self.setLoading(false)
					if success {
						profilePicture = nil
					} else {
						self.showNotification("Unable to set profile picture. Please try again", type: .error)
					}
					self.pictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
				}
			})
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.popoverPresentationController?.sourceView = view
		present(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			setLoading(true)
			uploadImage(image) { success in
				self.setLoading(false)
				if success {
					profilePicture = image
				} else {
					self.showNotification("Unable to set profile picture. Please try again", type: .error)
				}
				self.pictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
			}
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	func setLoading(_ isLoading: Bool) {
		changeButton.isEnabled = !isLoading
		if isLoading {
			pictureImageView.image = nil
			pictureActivityIndicator.startAnimating()
		} else {
			pictureActivityIndicator.stopAnimating()
		}
	}
	
	func uploadImage(_ image: UIImage?, completion: @escaping (Bool) -> Void) {
		guard let id = id else { return completion(false) }
		if let image = image?.fixedRotation {
			if let data = image.compressedData {
				storage.child("users/\(id)").putData(data, metadata: JPEG_METADATA) { _, error in
					if error == nil {
						storage.child("users/\(id)").downloadURL { url, error in
							if error == nil, let url = url, let currentUser = auth.currentUser {
								User.save(image: data)
								User.cache(id, image: image)
								currentUser.createProfileChangeRequest().photoURL = url
								completion(true)
							} else {
								completion(false)
							}
						}
					} else {
						completion(false)
					}
				}
			} else {
				completion(false)
			}
		} else {
			storage.child("users/\(id)").delete { error in
				if error == nil {
					profilePicture = nil
					User.save(image: nil)
					User.cache(id, image: nil)
					completion(true)
				} else {
					completion(false)
				}
			}
		}
	}
	
	@IBAction
	func nameClicked() {
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
	func emailClicked() {
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
	func linkClicked() {
		if let slug = slug {
			if let url = User.url(slug: slug) {
				present(SFSafariViewController(url: url), animated: true, completion: nil)
			} else {
				showNotification("Unable to load profile url. Please try again", type: .error)
			}
		} else {
			showNotification("Loading profile url...", type: .normal)
		}
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

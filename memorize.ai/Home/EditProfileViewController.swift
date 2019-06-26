import UIKit
import Firebase
import SafariServices

class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var pictureView: UIView!
	@IBOutlet weak var pictureImageView: UIImageView!
	@IBOutlet weak var changeButton: UIButton!
	@IBOutlet weak var pictureActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
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
		Option(image: #imageLiteral(resourceName: "Cards"), name: "Card Ratings", action: showCardRatings)
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		pictureImageView.layer.borderWidth = 0.5
		pictureImageView.layer.borderColor = UIColor.lightGray.cgColor
		pictureImageView.layer.masksToBounds = true
		navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share)), animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.profileModified, .settingAdded) { change in
			if change == .profileModified || change == .profilePicture {
				guard let slug = slug else { return }
				self.nameLabel.text = name
				self.emailLabel.text = email
				self.linkButton.setTitle("memorize.ai/\(slug)", for: .normal)
				self.pictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
			}
		}
		resizeOptionsTableView()
		updateCurrentViewController()
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
	
	func resizeOptionsTableView() {
		optionsTableViewHeightConstraint.constant = CGFloat(56 * options.count)
		view.layoutIfNeeded()
	}
	
	func showSettings() {
		performSegue(withIdentifier: "settings", sender: self)
	}
	
	func showUploads() {
		performSegue(withIdentifier: "uploads", sender: self)
	}
	
	func showDeckRatings() {
		performSegue(withIdentifier: "deckRatings", sender: self)
	}
	
	func showCardRatings() {
		performSegue(withIdentifier: "cardRatings", sender: self)
	}
	
	@IBAction func signOut() {
		let alertController = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let signOut = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
			do {
				try auth.signOut()
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
			} catch {
				self.showNotification("Unable to sign out. Please try again", type: .error)
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
		alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
			picker.sourceType = .camera
			self.present(picker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Choose Photo", style: .default) { _ in
			picker.sourceType = .photoLibrary
			self.present(picker, animated: true, completion: nil)
		})
		if profilePicture != nil, let id = id {
			alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
				self.pictureImageView.image = nil
				self.changeButton.isEnabled = false
				self.pictureActivityIndicator.startAnimating()
				self.uploadImage(nil) { success in
					self.pictureActivityIndicator.stopAnimating()
					self.changeButton.isEnabled = true
					if success {
						profilePicture = nil
					} else {
						self.showNotification("Unable to set profile picture. Please try again", type: .error)
					}
					self.pictureImageView.image = profilePicture ?? DEFAULT_PROFILE_PICTURE
				}
				storage.child("users/\(id)").delete { error in
					self.pictureActivityIndicator.stopAnimating()
					self.pictureImageView.image = #imageLiteral(resourceName: "Person")
					self.changeButton.isHidden = false
				}
			})
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			pictureImageView.image = nil
			changeButton.isEnabled = false
			pictureActivityIndicator.startAnimating()
			uploadImage(image) { success in
				self.pictureActivityIndicator.stopAnimating()
				self.changeButton.isEnabled = true
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
	
	func uploadImage(_ image: UIImage?, completion: @escaping (Bool) -> Void) {
		guard let id = id else { return completion(false) }
		if let image = image {
			if let data = image.compressedData {
				storage.child("users/\(id)").putData(data, metadata: JPEG_METADATA) { _, error in
					if error == nil {
						storage.child("users/\(id)").downloadURL { url, error in
							if error == nil, let url = url, let currentUser = auth.currentUser {
								User.save(image: data)
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
					completion(true)
				} else {
					completion(false)
				}
			}
		}
	}
	
	@IBAction func linkClicked() {
		guard let currentTitle = linkButton.currentTitle, let url = URL(string: "https://\(currentTitle)") else { return }
		present(SFSafariViewController(url: url), animated: true, completion: nil)
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

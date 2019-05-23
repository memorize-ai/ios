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
	
	let options = [Option(image: #imageLiteral(resourceName: "Settings"), name: "Settings", action: showSettings)]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		pictureImageView.layer.borderWidth = 0.5
		pictureImageView.layer.borderColor = UIColor.lightGray.cgColor
		pictureImageView.layer.masksToBounds = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.profileModified, .settingAdded) { change in
			if change == .profileModified || change == .profilePicture {
				self.nameLabel.text = name
				self.emailLabel.text = email
				self.linkButton.setTitle("memorize.ai/\(slug!)", for: .normal)
				self.pictureImageView.image = profilePicture ?? #imageLiteral(resourceName: "Person")
			}
		}
		resizeOptionsTableView()
	}
	
	func resizeOptionsTableView() {
		optionsTableViewHeightConstraint.constant = CGFloat(56 * options.count)
		view.layoutIfNeeded()
	}
	
	func showSettings() {
		performSegue(withIdentifier: "settings", sender: self)
	}
	
	@IBAction func signOut() {
		let alertController = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let signOut = UIAlertAction(title: "Sign Out", style: .default) { _ in
			do {
				try Auth.auth().signOut()
				deleteUser()
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
		alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
			picker.sourceType = .camera
			self.present(picker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Choose Photo", style: .default) { _ in
			picker.sourceType = .photoLibrary
			self.present(picker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
			self.pictureImageView.image = nil
			self.changeButton.isHidden = true
			self.pictureActivityIndicator.startAnimating()
			self.uploadImage(#imageLiteral(resourceName: "Person")) {
				self.pictureActivityIndicator.stopAnimating()
				self.pictureImageView.image = #imageLiteral(resourceName: "Person")
				self.changeButton.isHidden = false
			}
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			pictureImageView.image = nil
			changeButton.isHidden = true
			pictureActivityIndicator.startAnimating()
			uploadImage(image) {
				self.pictureActivityIndicator.stopAnimating()
				self.pictureImageView.image = image
				self.changeButton.isHidden = false
			}
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	func uploadImage(_ image: UIImage, completion: @escaping () -> Void) {
		profilePicture = image.compressed()
		if let data = image.compressedData() {
			let metadata = StorageMetadata()
			metadata.contentType = "image/jpeg"
			storage.child("users/\(id!)").putData(data, metadata: metadata) { _, error in
				guard error == nil else { return }
				saveImage(data)
				storage.child("users/\(id!)").downloadURL { url, error in
					guard error == nil, let url = url else { return }
					Auth.auth().currentUser?.createProfileChangeRequest().photoURL = url
					completion()
				}
			}
		} else {
			showAlert("Unable to set profile picture")
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OptionTableViewCell
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

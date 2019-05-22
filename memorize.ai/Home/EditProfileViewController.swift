import UIKit
import Firebase
import SafariServices

class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var pictureView: UIView!
	@IBOutlet weak var pictureImageView: UIImageView!
	@IBOutlet weak var changeButton: UIButton!
	@IBOutlet weak var pictureActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var linkButton: UIButton!
	@IBOutlet weak var settingsCollectionView: UICollectionView!
	@IBOutlet weak var settingsCollectionViewHeightConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		pictureImageView.layer.borderWidth = 0.5
		pictureImageView.layer.borderColor = UIColor.lightGray.cgColor
		pictureImageView.layer.masksToBounds = true
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: view.bounds.width - 40, height: 43)
		flowLayout.minimumLineSpacing = 8
		settingsCollectionView.collectionViewLayout = flowLayout
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.profileModified, .settingAdded) { change in
			if change == .profileModified || change == .profilePicture {
				self.nameLabel.text = name
				self.emailLabel.text = email
				self.linkButton.setTitle("memorize.ai/\(slug!)", for: .normal)
				self.pictureImageView.image = profilePicture ?? #imageLiteral(resourceName: "Person")
			} else if change == .settingAdded || change == .settingModified || change == .settingRemoved {
				self.settingsCollectionView.reloadData()
				self.resizeSettingsCollectionView()
			}
		}
	}
	
	func resizeSettingsCollectionView() {
		settingsCollectionViewHeightConstraint.constant = CGFloat(51 * settings.count - 8)
		view.layoutIfNeeded()
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
		guard let currentTitle = linkButton.currentTitle, let url = URL(string: currentTitle) else { return }
		present(SFSafariViewController(url: url), animated: true, completion: nil)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return settings.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SettingCollectionViewCell
		cell.load(settings[indexPath.item])
		return cell
	}
}

class SettingCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var descriptionLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var descriptionLabelBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var valueSwitch: UISwitch!
	
	var setting: Setting?
	
	func load(_ setting: Setting) {
		self.setting = setting
		layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		titleLabel.text = setting.title
		descriptionLabel.text = setting.description
		let noDescription = setting.description.isEmpty
		descriptionLabelHeightConstraint.constant = noDescription ? 0 : 12
		descriptionLabelBottomConstraint.constant = noDescription ? 2 : 6
		valueSwitch.setOn(setting.value as? Bool ?? false, animated: false)
	}
	
	@IBAction func valueSwitchChanged() {
		guard let id = id, let setting = setting else { return }
		firestore.document("users/\(id)/settings/\(setting.id)").setData(["value": valueSwitch.isOn]) { error in
			if error == nil {
				Setting.callHandler(setting)
			} else {
				self.valueSwitch.setOn(!self.valueSwitch.isOn, animated: true)
			}
		}
	}
}

import UIKit
import Firebase
import MobileCoreServices
import Photos

class EditUploadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var chooseFileView: UIView!
	@IBOutlet weak var fileImageView: UIImageView!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameBarView: UIView!
	@IBOutlet weak var metadataTableView: UITableView!
	@IBOutlet weak var uploadButton: UIButton!
	@IBOutlet weak var uploadActivityIndicator: UIActivityIndicatorView!
	
	var upload: Upload?
	var file: (name: String?, type: UploadType?, mime: String?, extension: String?, size: String?, data: Data?)
	var didChangeData = false
	var imagePickerSourceType: UIImagePickerController.SourceType?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		fileImageView.layer.borderColor = UIColor.lightGray.cgColor
		uploadButton.layer.borderColor = UIColor.lightGray.cgColor
		nameTextField.setKeyboard()
		if let upload = upload, let data = upload.data {
			file = (name: upload.name, type: upload.type, mime: upload.mime, extension: upload.extension, size: upload.size, data: data)
			fileImageView.image = upload.image
			nameTextField.text = upload.name
			chooseFileView.isHidden = true
			reloadPlayButton()
		}
		reloadUpload()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCurrentViewController()
	}
	
	var metadata: [(key: String, value: String)] {
		guard let size = file.size, let type = file.type?.rawValue, let ext = file.extension else { return [] }
		return [("Size", size), ("Type", type), ("Extension", ext)]
	}
	
	@IBAction
	func chooseFile() {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
			imagePicker.sourceType = .camera
			self.imagePickerSourceType = .camera
			self.present(imagePicker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Choose Photo", style: .default) { _ in
			if PHPhotoLibrary.authorizationStatus() == .authorized {
				imagePicker.sourceType = .photoLibrary
				self.imagePickerSourceType = .photoLibrary
				self.present(imagePicker, animated: true, completion: nil)
			} else {
				PHPhotoLibrary.requestAuthorization {
					guard $0 == .authorized else { return }
					imagePicker.sourceType = .photoLibrary
					self.imagePickerSourceType = .photoLibrary
					self.present(imagePicker, animated: true, completion: nil)
				}
			}
		})
		alert.addAction(UIAlertAction(title: "iCloud", style: .default) { _ in
			let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeImage), String(kUTTypeMP3)], in: .import)
			documentPicker.delegate = self
			self.present(documentPicker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Paste URL", style: .default) { _ in
			let urlAlert = UIAlertController(title: "Paste URL", message: nil, preferredStyle: .alert)
			urlAlert.addTextField {
				$0.placeholder = "File URL"
				$0.clearButtonMode = .whileEditing
			}
			urlAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			urlAlert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
				let urlString = urlAlert.textFields?.first?.text?.trim() ?? ""
				if urlString.isEmpty {
					self.showNotification("Please enter a valid URL", type: .error)
				} else if let url = URL(string: urlString), let data = try? Data(contentsOf: url), let _ext = urlString.split(separator: ".").last {
					let ext = String(_ext)
					if let mime = mimeTypeForExtension(ext), let type = UploadType(mime: mime) {
						switch type {
						case .image, .gif:
							if let image = UIImage(data: data) {
								self.saveImage(image, data: data, extension: ext)
							} else {
								self.showNotification("Unable to load image from URL. Please try again", type: .error)
							}
						case .audio:
							self.fileImageView.image = #imageLiteral(resourceName: "Sound")
							self.file.type = type
							self.file.mime = mime
							self.file.extension = ext
							self.file.size = data.size
							self.file.data = data
							self.didPickFile()
							self.reloadUpload()
						}
					} else {
						self.showNotification("Invalid file type", type: .error)
					}
				} else {
					self.showNotification("Unable to get file contents from URL. Please try again", type: .error)
				}
			})
			self.present(urlAlert, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let data = image.compressedData {
			switch imagePickerSourceType {
			case .some(.camera):
				saveImage(image, data: data, extension: "heic")
			case .some(.photoLibrary):
				if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset, let ext = PHAssetResource.assetResources(for: asset).first?.originalFilename.split(separator: ".").last {
					saveImage(image, data: data, extension: String(ext))
				} else {
					showNotification("Unable to select image. Please choose another image", type: .error)
				}
			default:
				showNotification("Error when selecting image. Please try again", type: .error)
			}
		} else {
			showNotification("Unable to select image. Please choose another image", type: .error)
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	func saveImage(_ image: UIImage, data: Data, extension ext: String) {
		if let mime = mimeTypeForExtension(ext), let type = UploadType(mime: mime) {
			fileImageView.image = image
			file.type = type
			file.mime = mime
			file.extension = ext
			file.size = data.size
			file.data = data
			didPickFile()
			reloadUpload()
		} else {
			showNotification("Unable to select image. Please choose another image", type: .error)
		}
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		if let url = urls.first, let data = try? Data(contentsOf: url), let _ext = url.absoluteString.split(separator: ".").last {
			let ext = String(_ext)
			if let mime = mimeTypeForExtension(ext), let type = UploadType(mime: mime) {
				switch type {
				case .image, .gif:
					if let image = UIImage(data: data) {
						fileImageView.image = image
					} else {
						showNotification("Error when displaying image. Please try again", type: .error)
						dismiss(animated: true, completion: nil)
						return
					}
				case .audio:
					fileImageView.image = #imageLiteral(resourceName: "Sound")
				}
				file.type = type
				file.mime = mime
				file.extension = ext
				file.size = data.size
				file.data = data
				didPickFile()
				reloadUpload()
			} else {
				showNotification("Unable to select file. Please try again", type: .error)
			}
		} else {
			showNotification("Unable to select file. Please try again", type: .error)
		}
		dismiss(animated: true, completion: nil)
	}
	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		dismiss(animated: true, completion: nil)
	}
	
	func didPickFile() {
		didChangeData = true
		chooseFileView.isHidden = true
		reloadPlayButton()
	}
	
	func reloadPlayButton() {
		switch file.type {
		case .some(.audio):
			playButton.isHidden = false
		default:
			playButton.isHidden = true
		}
	}
	
	@IBAction
	func playAudio() {
		if let data = file.data {
			if Audio.isPlaying {
				Audio.stop()
				playButton.setImage(Audio.image(for: .ready), for: .normal)
			} else {
				playButton.setImage(Audio.image(for: .stop), for: .normal)
				Audio.play(data: data) { success in
					if success {
						self.playButton.setImage(Audio.image(for: .ready), for: .normal)
					} else {
						self.showNotification("Unable to play audio. Please try again", type: .error)
					}
				}
			}
		} else {
			showNotification("Unable to get audio data. Please try again", type: .error)
		}
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.nameBarView.transform = CGAffineTransform(scaleX: 1.01, y: 2)
			self.nameBarView.backgroundColor = DEFAULT_BLUE_COLOR
		}, completion: nil)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.nameBarView.transform = .identity
			self.nameBarView.backgroundColor = .lightGray
		}, completion: nil)
	}
	
	@IBAction
	func nameChanged() {
		guard let name = nameTextField.text?.trim() else { return }
		file.name = name.isEmpty ? nil : name
		reloadUpload()
	}
	
	@IBAction
	func submitUpload() {
		guard let id = id, let name = file.name, let type = file.type?.rawValue, let mime = file.mime, let ext = file.extension, let size = file.size, let data = file.data else { return }
		let now = Date()
		let metadata = StorageMetadata(mime: mime)
		setLoading(true)
		if let upload = upload {
			firestore.document("users/\(id)/uploads/\(upload.id)").updateData([
				"name": name,
				"type": type,
				"mime": mime,
				"extension": ext,
				"size": size
			]) { error in
				if error == nil {
					if self.didChangeData {
						Upload.storage.child("\(id)/\(upload.id)").putData(data, metadata: metadata) { _, error in
							self.setLoading(false)
							if error == nil {
								upload.data = data
								Cache.remove(.upload, key: upload.id)
								self.showNotification("Uploaded file", type: .success)
							} else {
								self.showNotification("Unable to upload file. Please try again", type: .error)
							}
						}
					} else {
						self.setLoading(false)
						self.showNotification("Edited upload", type: .success)
					}
				} else {
					self.setLoading(false)
					self.showNotification("Unable to upload file. Please try again", type: .error)
				}
			}
		} else {
			var documentReference: DocumentReference?
			documentReference = firestore.collection("users/\(id)/uploads").addDocument(data: [
				"name": name,
				"created": now,
				"updated": now,
				"type": type,
				"mime": mime,
				"extension": ext,
				"size": size
			]) { error in
				if error == nil, let uploadId = documentReference?.documentID {
					Upload.storage.child("\(id)/\(uploadId)").putData(data, metadata: metadata) { _, error in
						self.setLoading(false)
						if error == nil {
							if let localUpload = Upload.get(uploadId) {
								localUpload.data = data
								Cache.remove(.upload, key: uploadId)
							}
							self.navigationController?.popViewController(animated: true)
							self.navigationController?.topViewController?.showNotification("Uploaded file", type: .success)
						} else {
							self.showNotification("Unable to upload file. Please try again", type: .error)
						}
					}
				} else {
					self.setLoading(false)
					self.showNotification("Unable to upload file. Please try again", type: .error)
				}
			}
		}
	}
	
	func reloadUpload() {
		if file.name == nil || file.type == nil || file.mime == nil || file.extension == nil || file.size == nil || file.data == nil {
			setEnabled(false)
		} else if let upload = upload, upload.name == file.name && upload.type == file.type && upload.mime == file.mime && upload.extension == file.extension && upload.size == file.size {
			setEnabled(false)
		} else {
			setEnabled(true)
		}
		metadataTableView.reloadData()
	}
	
	func setEnabled(_ isEnabled: Bool) {
		uploadButton.isEnabled = isEnabled
		uploadButton.setTitleColor(isEnabled ? #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1) : #colorLiteral(red: 0.8264711499, green: 0.8266105652, blue: 0.8264527917, alpha: 1), for: .normal)
		uploadButton.backgroundColor = isEnabled ? DEFAULT_BLUE_COLOR : #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)
		uploadButton.layer.borderWidth = isEnabled ? 0 : 1
	}
	
	func setLoading(_ isLoading: Bool) {
		uploadButton.isEnabled = !isLoading
		uploadButton.setTitle(isLoading ? nil : "UPLOAD", for: .normal)
		if isLoading {
			uploadActivityIndicator.startAnimating()
		} else {
			uploadActivityIndicator.stopAnimating()
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return metadata.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = metadata[indexPath.row]
		cell.textLabel?.text = element.key
		cell.detailTextLabel?.text = element.value
		return cell
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

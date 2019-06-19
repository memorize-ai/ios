import UIKit
import Firebase
import MobileCoreServices

class EditUploadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var chooseFileLabel: UILabel!
	@IBOutlet weak var fileImageView: UIImageView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameBarView: UIView!
	@IBOutlet weak var metadataTableView: UITableView!
	@IBOutlet weak var uploadButton: UIButton!
	
	var upload: Upload?
	var file: (name: String?, type: UploadType?, mime: String?, extension: String?, size: String?, data: Data?) = (nil, nil, nil, nil, nil, nil)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let upload = upload, let data = upload.data {
			file = (name: upload.name, type: upload.type, mime: upload.mime, extension: upload.extension, size: upload.size, data: data)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCurrentViewController()
	}
	
	var metadata: [(key: String, value: String)] {
		guard let size = file.size, let type = file.type?.rawValue, let ext = file.extension else { return [] }
		return [
			("Size", size),
			("Type", type),
			("Ext", ext)
		]
	}
	
	@IBAction func chooseFile() {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
			imagePicker.sourceType = .camera
			self.present(imagePicker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Choose Photo", style: .default) { _ in
			imagePicker.sourceType = .photoLibrary
			self.present(imagePicker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "iCloud", style: .default) { _ in
			let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeImage), String(kUTTypeMP3)], in: .import)
			documentPicker.delegate = self
			self.present(documentPicker, animated: true, completion: nil)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		dismiss(animated: true, completion: nil)
		guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
		fileImageView.image = image
		file.data = image.compressedData()
		reloadUpload()
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func submitUpload() {
		guard let id = id, let name = file.name, let type = file.type?.rawValue, let mime = file.mime, let ext = file.extension, let size = file.size, let data = file.data else { return }
		let now = Date()
		let metadata = StorageMetadata.from(mime: mime)
		showNotification("Uploading...", type: .normal)
		if let upload = upload {
			firestore.document("users/\(id)/uploads/\(upload.id)").updateData([
				"name": name,
				"type": type,
				"mime": mime,
				"extension": ext,
				"size": size
			]) { error in
				if error == nil {
					Upload.storage.child("\(id)/\(upload.id)").putData(data, metadata: metadata) { _, error in
						if error == nil {
							self.showNotification("Uploaded file", type: .success)
						} else {
							self.showNotification("Unable to upload file. Please try again", type: .error)
						}
					}
				} else {
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
						if error == nil {
							self.navigationController?.popViewController(animated: true)
							self.navigationController?.topViewController?.showNotification("Uploaded file", type: .success) // will this work?
						} else {
							self.showNotification("Unable to upload file. Please try again", type: .error)
						}
					}
				} else {
					self.showNotification("Unable to upload file. Please try again", type: .error)
				}
			}
		}
	}
	
	func reloadUpload() {
		
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
}

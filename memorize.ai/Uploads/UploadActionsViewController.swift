import UIKit

class UploadActionsViewController: UIViewController {
	@IBOutlet weak var uploadView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var deleteActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var sizeLabel: UILabel!
	@IBOutlet weak var extensionLabel: UILabel!
	@IBOutlet weak var lastUpdatedLabel: UILabel!
	@IBOutlet weak var createdLabel: UILabel!
	
	var upload: Upload?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		uploadView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.uploadView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.uploadModified) { change in
			if change == .uploadAdded || change == .uploadModified || change == .uploadRemoved {
				(self.parent as? UploadsViewController)?.reloadUploads()
			}
			if change == .uploadModified {
				self.reloadLabels()
			} else if change == .uploadRemoved && !(uploads.contains { $0.id == self.upload?.id }) {
				self.hide()
			}
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		titleBar.round(corners: [.topLeft, .topRight], radius: 10)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		if let editUploadVC = segue.destination as? EditUploadViewController {
			editUploadVC.upload = upload
		}
	}
	
	func reloadLabels() {
		guard let upload = upload else { return }
		nameLabel.text = upload.name
		typeLabel.text = upload.type.rawValue
		sizeLabel.text = upload.size
		extensionLabel.text = upload.extension
		lastUpdatedLabel.text = upload.updated.format()
		createdLabel.text = upload.created.format()
	}
	
	@IBAction
	func delete() {
		guard let id = id, let upload = upload else { return }
		let alertController = UIAlertController(title: "Are you sure?", message: "Every card using this upload will be unable to use it anymore. This action cannot be undone", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
			self.setDeleteLoading(true)
			firestore.document("users/\(id)/uploads/\(upload.id)").delete { error in
				if error == nil {
					Upload.storage.child("\(id)/\(upload.id)").delete { error in
						self.setDeleteLoading(false)
						if error == nil {
							self.hide()
							Cache.remove(.upload, key: upload.id)
						} else {
							self.showNotification("Unable to delete upload. Please try again", type: .error)
						}
					}
				} else {
					self.setDeleteLoading(false)
					self.showNotification("Unable to delete upload. Please try again", type: .error)
				}
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	func setDeleteLoading(_ isLoading: Bool) {
		deleteButton.isHidden = isLoading
		if isLoading {
			deleteActivityIndicator.startAnimating()
		} else {
			deleteActivityIndicator.stopAnimating()
		}
	}
	
	@IBAction
	func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.uploadView.transform = CGAffineTransform(scaleX: 0, y: 0)
			self.view.backgroundColor = .clear
		}) {
			guard $0 else { return }
			self.view.removeFromSuperview()
		}
	}
}

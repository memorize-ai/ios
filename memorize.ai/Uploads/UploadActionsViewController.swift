import UIKit

class UploadActionsViewController: UIViewController {
	@IBOutlet weak var uploadView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var deleteActivityIndicator: UIActivityIndicatorView!
	
	var upload: Upload?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners([.topLeft, .topRight], radius: 10)
		uploadView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.uploadView.transform = .identity
		}, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		if let editUploadVC = segue.destination as? EditUploadViewController {
			editUploadVC.upload = upload
		}
	}
	
	@IBAction func delete() {
		guard let id = id, let upload = upload else { return }
		let alertController = UIAlertController(title: "Are you sure?", message: "Every card using this upload will be unable to use it anymore. This action cannot be undone", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
			self.setDeleteLoading(true)
			firestore.document("users/\(id)/uploads/\(upload.id)").delete { error in
				self.setDeleteLoading(false)
				if error == nil {
					self.hide()
				} else {
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
	
	@IBAction func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.uploadView.transform = CGAffineTransform(scaleX: 0, y: 0)
			self.view.backgroundColor = .clear
		}) {
			guard $0 else { return }
			self.view.removeFromSuperview()
		}
	}
}

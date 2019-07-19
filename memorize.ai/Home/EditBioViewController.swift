import UIKit

class EditBioViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var bioTextView: UITextView!
	@IBOutlet weak var bioTextViewBottomConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let deleteBioButton = UIButton(type: .custom)
		deleteBioButton.setImage(#imageLiteral(resourceName: "Trash Can"), for: .normal)
		deleteBioButton.addTarget(self, action: #selector(deleteBio), for: .touchUpInside)
		deleteBioButton.widthAnchor.constraint(equalToConstant: 26).isActive = true
		deleteBioButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
		navigationItem.setRightBarButtonItems([
			UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveBio)),
			UIBarButtonItem(customView: deleteBioButton)
		], animated: true)
		bioTextView.setKeyboard(.plain)
		loadBio()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		KeyboardHandler.addListener(self, up: keyboardUp, down: keyboardDown)
		updateCurrentViewController()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		KeyboardHandler.removeListener(self)
	}
	
	@objc
	func saveBio() {
		guard let id = id else { return }
		setSaveButtonEnabled(false)
		let trimmedText = bioTextView.text.trim()
		firestore.document("users/\(id)").updateData(["bio": trimmedText]) { error in
			guard error == nil else {
				self.setSaveButtonEnabled(true)
				self.showNotification("Unable to save bio. Please try again", type: .error)
				return
			}
			self.bioTextView.text = trimmedText
			self.showNotification("Saved", type: .success)
		}
	}
	
	@objc
	func deleteBio() {
		let alertController = UIAlertController(title: "Are you sure?", message: "Your bio will be deleted", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
			guard let id = id else { return }
			self.setDeleteButtonEnabled(false)
			firestore.document("users/\(id)").updateData(["bio": ""]) { error in
				guard error == nil else {
					self.setDeleteButtonEnabled(true)
					self.showNotification("Unable to delete bio. Please try again", type: .error)
					return
				}
				self.bioTextView.text = ""
				self.navigationController?.popViewController(animated: true)
			}
		})
		present(alertController, animated: true)
	}
	
	func keyboardUp() {
		bioTextViewBottomConstraint.constant = keyboardOffset
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded)
	}
	
	func keyboardDown() {
		bioTextViewBottomConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: view.layoutIfNeeded)
	}
	
	func loadBio() {
		guard let bio = bio else { return }
		bioTextView.text = bio
		setSaveButtonEnabled(false)
		setDeleteButtonEnabled(!bio.isEmpty)
	}
	
	func textViewDidChange(_ textView: UITextView) {
		guard let bio = bio, let text = bioTextView.text else { return }
		setSaveButtonEnabled(text != bio)
		setDeleteButtonEnabled(!text.isEmpty)
	}
	
	func setSaveButtonEnabled(_ enabled: Bool) {
		guard let barButton = navigationItem.rightBarButtonItems?.first else { return }
		barButton.isEnabled = enabled
		barButton.tintColor = enabled ? .white : #colorLiteral(red: 0.9841352105, green: 0.9841352105, blue: 0.9841352105, alpha: 1)
	}
	
	func setDeleteButtonEnabled(_ enabled: Bool) {
		guard let barButton = navigationItem.rightBarButtonItems?.last else { return }
		barButton.isEnabled = enabled
		barButton.tintColor = enabled ? .white : #colorLiteral(red: 0.9841352105, green: 0.9841352105, blue: 0.9841352105, alpha: 1)
	}
}

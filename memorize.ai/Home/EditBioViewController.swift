import UIKit

class EditBioViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var bioTextView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.setRightBarButton(UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveBio)), animated: true)
	}
	
	@objc
	func saveBio() {
		guard let id = id else { return }
		let trimmedText = bioTextView.text.trim()
		firestore.document("users/\(id)").updateData(["bio": trimmedText]) { error in
			guard error == nil else { return self.showNotification("Unable to save. Please try again", type: .error) }
			self.bioTextView.text = trimmedText
			self.showNotification("Saved", type: .success)
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		guard let bio = bio else { return }
		setSaveButtonEnabled(bioTextView.text != bio)
	}
	
	func setSaveButtonEnabled(_ enabled: Bool) {
		guard let barButton = navigationItem.rightBarButtonItem else { return }
		barButton.isEnabled = enabled
		barButton.tintColor = enabled ? .white : #colorLiteral(red: 0.9841352105, green: 0.9841352105, blue: 0.9841352105, alpha: 1)
	}
}

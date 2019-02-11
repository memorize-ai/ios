import UIKit
import Firebase

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.setRightBarButton(UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)), animated: true)
    }
	
	@objc func signOut() {
		let alertController = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let signOut = UIAlertAction(title: "Sign Out", style: .default) { action in
			do {
				try Auth.auth().signOut()
				deleteLogin()
				self.performSegue(withIdentifier: "signOut", sender: self)
			} catch let error {
				self.showAlert(error.localizedDescription)
			}
		}
		alertController.addAction(cancel)
		alertController.addAction(signOut)
		present(alertController, animated: true, completion: nil)
	}
}

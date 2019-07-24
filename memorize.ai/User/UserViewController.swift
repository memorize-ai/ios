import UIKit

class UserViewController: UIViewController {
	var uid: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@discardableResult
	static func show(_ viewController: UIViewController, id uid: String) -> Bool {
		guard let userVC = viewController.storyboard?.instantiateViewController(withIdentifier: "user") as? UserViewController else { return false }
		userVC.uid = uid
		viewController.navigationController?.pushViewController(userVC, animated: true)
		return true
	}
}

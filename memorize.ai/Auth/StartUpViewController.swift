import UIKit

class StartUpViewController: UIViewController {
	@IBOutlet weak var signUpButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		signUpButton.layer.borderWidth = 1
		signUpButton.layer.borderColor = UIColor.white.cgColor
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler(nil)
		navigationController?.isNavigationBarHidden = true
		startup = false
	}
}

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
		navigationController?.setNavigationBarHidden(true, animated: true)
		startup = false
		shouldLoadDecks = true
	}
}

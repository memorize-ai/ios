import UIKit

class RecapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: true)
		let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(back))
		navigationItem.setRightBarButton(done, animated: true)
    }
	
	@objc func back() {
		performSegue(withIdentifier: "done", sender: self)
	}
}

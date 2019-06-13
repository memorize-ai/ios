import UIKit
import Firebase

class UploadViewController: UIViewController {
	@IBOutlet weak var fileImageView: UIImageView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameBarView: UIView!
	@IBOutlet weak var uploadButton: UIButton!
	
	var data: Data?
	var type: UploadType?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCurrentViewController()
	}
	
	@IBAction func chooseFile() {
		
	}
	
	@IBAction func upload() {
		
	}
}

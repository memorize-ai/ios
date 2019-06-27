import UIKit
import WebKit
import Down

fileprivate var tutorial: String?

class TutorialViewController: UIViewController {
	@IBOutlet weak var webView: WKWebView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let tutorial = tutorial {
			showTutorial(tutorial)
		} else {
			firestore.document("markdown/ios-tutorial").addSnapshotListener { snapshot, error in
				if error == nil, let text = snapshot?.get("text") as? String {
					tutorial = text
					self.showTutorial(text)
				} else {
					self.navigationController?.popViewController(animated: true)
				}
			}
		}
	}
	
	func showTutorial(_ text: String) {
		webView.render(text, fontSize: 35, textColor: "000000", backgroundColor: "ffffff")
	}
}

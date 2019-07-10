import UIKit
import WebKit

fileprivate var tutorial: String?

class TutorialViewController: UIViewController {
	@IBOutlet weak var webView: WKWebView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let tutorial = tutorial {
			showTutorial(tutorial)
		} else {
			listeners["markdown/ios-tutorial"] = firestore.document("markdown/ios-tutorial").addSnapshotListener { snapshot, error in
				if error == nil, let text = snapshot?.get("text") as? String {
					tutorial = self.showTutorial(text)
				} else {
					self.navigationController?.popViewController(animated: true)
				}
			}
		}
	}
	
	@discardableResult
	func showTutorial(_ text: String) -> String {
		webView.render(text, fontSize: 35)
		return text
	}
}

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
				if error == nil, let snapshot = snapshot, let text = snapshot.get("text") as? String, let html = try? Down(markdownString: text).toHTML() {
					tutorial = html
					self.showTutorial(html)
				} else {
					self.navigationController?.popViewController(animated: true)
				}
			}
		}
	}
	
	func showTutorial(_ text: String) {
		webView.loadHTMLString(text, baseURL: nil)
	}
}

import Foundation
import CoreData
import Firebase
import AudioToolbox
import WebKit
import Down

let firestore = Firestore.firestore()
let storage = Storage.storage().reference()
let functions = Functions.functions()
let auth = Auth.auth()
let defaults = UserDefaults.standard
var startup = true
var shouldLoadDecks = false
var currentViewController: UIViewController?

extension DocumentSnapshot {
	func getDate(_ field: String) -> Date? {
		return (get(field) as? Timestamp)?.dateValue()
	}
}

extension WKWebView {
	func render(_ text: String, fontSize: Int, textColor: String, backgroundColor: String) {
		let unescapedText = text.replacingOccurrences(of: "\\", with: "\\\\")
		loadHTMLString("""
			<!DOCTYPE html>
			<html>
				<head>
					<link rel="stylesheet" href="katex.min.css">
					<script src="katex.min.js"></script>
					<script src="auto-render.min.js"></script>
					<link rel="stylesheet" href="prism.css">
					<style>
						html, body {
							font-family: Helvetica;
							font-size: \(fontSize)px;
							color: #\(textColor);
							background-color: #\(backgroundColor);
						}
					</style>
				</head>
				<body>
					<div>\((try? Down(markdownString: unescapedText).toHTML()) ?? unescapedText)</div>
					<script>renderMathInElement(document.body)</script>
					<script src="prism.js"></script>
				</body>
			</html>
		""", baseURL: URL(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true))
	}
}

func buzz() {
	AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

extension UIViewController {
	func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func showAlert(_ title: String, _ message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(action)
		present(alertController, animated: true, completion: nil)
	}
	
	func showAlert(_ message: String) {
		buzz()
		showAlert("Error", message)
	}
	
	func updateCurrentViewController() {
		currentViewController = self
	}
}

extension String {
	func trim() -> String {
		return trimmingCharacters(in: .whitespaces)
	}
	
	func trimAll() -> String {
		return replacingOccurrences(of: " ", with: "")
	}
	
	func checkEmail() -> Bool {
		return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
	}
	
	func clean() -> String {
		return replacingOccurrences(of: #"#|\\[\(\)\[\]]|\\|\*\*|_|\n*```\w*\n*"#, with: "", options: .regularExpression).trim()
	}
}

extension UIView {
	func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}
}

extension Date {
	func format(_ format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
	
	func format() -> String {
		return format("MMM d, yyyy @ h:mm a")
	}
	
	func elapsed() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.zeroFormattingBehavior = .dropAll
		formatter.maximumUnitCount = 1
		formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
		return "\(formatter.string(from: self, to: Date()) ?? "") ago"
	}
}

extension UIImage {
	func compressedData() -> Data? {
		return jpegData(compressionQuality: COMPRESSION_QUALITY)
	}
	
	func compressed() -> UIImage? {
		guard let data = compressedData() else { return nil }
		return UIImage(data: data)
	}
}

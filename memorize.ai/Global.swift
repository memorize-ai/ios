import Foundation
import Firebase
import AudioToolbox
import WebKit
import Down
import SwiftyMimeTypes

let firestore = Firestore.firestore()
let storage = Storage.storage().reference()
let functions = Functions.functions()
let auth = Auth.auth()
let defaults = UserDefaults.standard
var startup = true
var shouldLoadDecks = false

func buzz() {
	AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

func mimeTypeForExtension(_ ext: String) -> String? {
	switch ext {
	case "heic":
		return "image/heic"
	default:
		return MimeTypes.mimeType(forExtension: ext)
	}
}

func metadataForExtension(_ ext: String) -> StorageMetadata? {
	guard let mime = mimeTypeForExtension(ext) else { return nil }
	return StorageMetadata.from(mime: mime)
}

extension StorageMetadata {
	static func from(mime: String) -> StorageMetadata {
		let metadata = StorageMetadata()
		metadata.contentType = mime
		return metadata
	}
}

extension Collection {
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

extension DocumentSnapshot {
	func getDate(_ field: String) -> Date? {
		return (get(field) as? Timestamp)?.dateValue()
	}
}

extension WKWebView {
	func render(_ text: String, fontSize: Int, textColor: String, backgroundColor: String) {
		let escapedText = Card.escape(text)
		loadHTMLString("""
			<!DOCTYPE html>
			<html>
				<head>
					<link rel="stylesheet" href="katex.min.css">
					<script src="katex.min.js"></script>
					<script src="auto-render.min.js"></script>
					<link rel="stylesheet" href="prism.css">
					<style>
						html,
						body {
							font-family: Helvetica;
							font-size: \(fontSize)px;
							color: #\(textColor);
							background-color: #\(backgroundColor);
						}
					</style>
				</head>
				<body>
					<div>\((try? Down(markdownString: escapedText).toHTML()) ?? escapedText)</div>
					<script>renderMathInElement(document.body)</script>
					<script src="prism.js"></script>
				</body>
			</html>
		""", baseURL: URL(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true))
	}
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
	
	func match(_ regex: String) -> [[String]] {
		let nsString = self as NSString
		return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, count)).map { match in
			(0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
		} ?? []
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
	
	func formatCompact() -> String {
		return format("MMM d, yyyy")
	}
	
	func elapsed(to date: Date = Date()) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.zeroFormattingBehavior = .dropAll
		formatter.maximumUnitCount = 1
		formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
		return "\(formatter.string(from: self, to: date) ?? "") ago"
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

extension Data {
	var size: String {
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [count < 100 * 1024 ? .useKB : .useMB, .useGB]
		formatter.countStyle = .file
		return formatter.string(fromByteCount: Int64(count))
	}
}

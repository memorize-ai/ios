import Foundation
import Firebase
import AudioToolbox
import WebKit
import Down
import SwiftGifOrigin

let firestore = Firestore.firestore()
let storage = Storage.storage().reference()
let functions = Functions.functions()
let auth = Auth.auth()
let defaults = UserDefaults.standard
let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
var startup = true
var shouldLoadDecks = false
var shouldShowEditProfileTip = false
var registerForNotifications: (() -> Void)?

@discardableResult
func saveManagedContext() -> Bool {
	guard let managedContext = managedContext else { return false }
	guard managedContext.hasChanges else { return true }
	return (try? managedContext.save()) == nil
}

func buzz() {
	AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

func getStarsTrailingConstraint(width: CGFloat, ratings: DeckRatings) -> CGFloat {
	return getStarsTrailingConstraint(width: width, rating: ratings.average)
}

func getStarsTrailingConstraint(width: CGFloat, rating: Double) -> CGFloat {
	return width * (rating == 0 ? 1 : CGFloat(5 - rating) / 5)
}

extension StorageMetadata {
	convenience init(mime: String) {
		self.init()
		contentType = mime
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
	func render(_ text: String, fontSize: Int, textColor: String = "000", backgroundColor: String = "fff") {
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
	var isValidEmail: Bool {
		return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
	}
	
	func trim() -> String {
		return trimmingCharacters(in: .whitespaces)
	}
	
	func trimAll() -> String {
		return replacingOccurrences(of: " ", with: "")
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
	func round(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}
}

extension UILabel {
	var isTruncated: Bool {
		guard let text = text, let font = font else { return false }
		return (text as NSString).boundingRect(
			with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
			options: .usesLineFragmentOrigin,
			attributes: [.font: font],
			context: nil
		).size.height > bounds.size.height
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
		formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
		return "\(formatter.string(from: self, to: date) ?? "") ago"
	}
}

extension UIImage {
	var compressedData: Data? {
		return jpegData(compressionQuality: COMPRESSION_QUALITY)
	}
	
	var compressed: UIImage? {
		guard let data = compressedData else { return nil }
		return UIImage(data: data)
	}
	
	var fixedRotation: UIImage {
		if imageOrientation == .up { return self }
		UIGraphicsBeginImageContext(size)
		draw(in: CGRect(origin: .zero, size: size))
		let copy = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return copy ?? self
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

extension Double {
	var formatted: String {
		let absolute = abs(self)
		func greaterThan(_ number: Double) -> Bool {
			return absolute >= number
		}
		func format(_ number: Double, ext: String) -> String {
			let str = String((self / number).oneDecimalPlace)
			return "\(str.suffix(2) == ".0" ? String(str.prefix(str.count - 2)) : str)\(ext)"
		}
		switch true {
		case greaterThan(1000000000000):
			return format(1000000000000, ext: "T")
		case greaterThan(1000000000):
			return format(1000000000, ext: "B")
		case greaterThan(1000000):
			return format(1000000, ext: "M")
		case greaterThan(1000):
			return format(1000, ext: "K")
		case absolute < 1000:
			return format(1, ext: "")
		default:
			return "overflow"
		}
	}
	
	var oneDecimalPlace: Double {
		return (self * 10).rounded() / 10
	}
	
	var plural: String {
		return self == 1 ? "" : "s"
	}
}

extension Int {
	var formatted: String {
		return Double(self).formatted
	}
	
	var plural: String {
		return Double(self).plural
	}
}

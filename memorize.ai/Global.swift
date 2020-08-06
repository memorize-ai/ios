import SwiftUI
import CryptoKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseFunctions

let auth = Auth.auth()
let firestore = Firestore.firestore()
let storage = Storage.storage().reference()
let functions = Functions.functions()

let defaults = UserDefaults.standard

let SCREEN_SIZE = UIScreen.main.bounds.size
let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
let MAIN_BUNDLE_PATH = Bundle.main.bundlePath
let WEB_VIEW_BASE_URL = URL(fileURLWithPath: MAIN_BUNDLE_PATH, isDirectory: true)

var currentViewController: UIViewController! {
	UIApplication.shared.windows.last?.rootViewController
}

var randomId: String {
	firestore.collection("empty").document().documentID
}

func withDelay(_ duration: TimeInterval, body: @escaping () -> Void) {
	Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
		body()
	}
}

func onThread(_ thread: DispatchQoS.QoSClass?, execute block: @escaping () -> Void) {
	(thread.map { DispatchQueue.global(qos: $0) } ?? .main).async(execute: block)
}

func onBackgroundThread(execute block: @escaping () -> Void) {
	onThread(.background, execute: block)
}

func onMainThread(execute block: @escaping () -> Void) {
	onThread(nil, execute: block)
}

func popUpWithAnimation(body: () -> Void) {
	withAnimation(.easeIn(duration: 0.15), body)
}

func round(_ number: Double, toClosestMultipleOf multiple: Double) -> Double {
	multiple * round(number / multiple)
}

enum Corner {
	case topLeft
	case topRight
	case bottomRight
	case bottomLeft
	
	func point(withPadding padding: CGFloat) -> CGPoint {
		switch self {
		case .topLeft:
			return .init(x: padding, y: padding)
		case .topRight:
			return .init(x: SCREEN_SIZE.width - padding, y: padding)
		case .bottomRight:
			return .init(x: SCREEN_SIZE.width - padding, y: SCREEN_SIZE.height - padding)
		case .bottomLeft:
			return .init(x: padding, y: SCREEN_SIZE.height - padding)
		}
	}
}

func share(
	items: [Any],
	excludedActivityTypes: [UIActivity.ActivityType]? = nil,
	corner: Corner,
	padding: CGFloat = 30
) {
	let vc = UIActivityViewController(
		activityItems: items,
		applicationActivities: nil
	)
	
	vc.excludedActivityTypes = excludedActivityTypes
	vc.popoverPresentationController?.sourceView = currentViewController.view
	vc.popoverPresentationController?.sourceRect = .init(
		origin: corner.point(withPadding: padding),
		size: .zero
	)
	
	currentViewController.present(vc, animated: true)
}

func share(
	_ item: Any,
	excludedActivityTypes: [UIActivity.ActivityType]? = nil,
	corner: Corner,
	padding: CGFloat = 30
) {
	share(
		items: [item],
		excludedActivityTypes: excludedActivityTypes,
		corner: corner,
		padding: padding
	)
}

func showAlert(
	title: String?,
	message: String?,
	preferredStyle: UIAlertController.Style = .alert,
	handler: (UIAlertController) -> Void
) {
	let alert = UIAlertController(
		title: title,
		message: message,
		preferredStyle: preferredStyle
	)
	handler(alert)
	currentViewController.present(alert, animated: true)
}

func showAlert(
	title: String?,
	message: String?,
	preferredStyle: UIAlertController.Style = .alert
) {
	showAlert(title: title, message: message, preferredStyle: preferredStyle) { alert in
		alert.addAction(.init(title: "OK", style: .default))
	}
}

func createRandomId(withLength length: Int) -> String {
	var acc = ""
	
	for _ in 0..<length {
		guard let character = VALID_ID_CHARACTERS.randomElement() else { continue }
		acc.append(character)
	}
	
	return acc
}

func slugify(_ string: String, delimiter: String = "-") -> String {
	let slug = string
		.replacingOccurrences(
			of: #"[\s\:\/\?#@\[\]\-_!\$&'\(\)\*\+\.\,;=]+"#,
			with: " ",
			options: .regularExpression
		)
		.trimmingCharacters(in: .whitespacesAndNewlines)
		.replacingOccurrences(
			of: #"\s+"#,
			with: delimiter,
			options: .regularExpression
		)
		.lowercased()
	
	return slug.isEmpty
		? .init(repeating: delimiter, count: string.count)
		: slug
}

func sha256(_ text: String) -> String {
	SHA256.hash(data: Data(text.utf8))
		.compactMap { .init(format: "%02x", $0) }
		.joined()
}

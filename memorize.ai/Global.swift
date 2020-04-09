import SwiftUI
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

func share(
	items: [Any],
	excludedActivityTypes: [UIActivity.ActivityType]? = nil
) {
	let vc = UIActivityViewController(
		activityItems: items,
		applicationActivities: nil
	)
	vc.excludedActivityTypes = excludedActivityTypes
	vc.popoverPresentationController?.sourceView = currentViewController.view
	currentViewController.present(vc, animated: true)
}

func share(
	_ item: Any,
	excludedActivityTypes: [UIActivity.ActivityType]? = nil
) {
	share(items: [item], excludedActivityTypes: excludedActivityTypes)
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

func numberOfGridColumns(
	width: CGFloat,
	cellWidth: CGFloat,
	horizontalSpacing: CGFloat
) -> Int {
	.init((width + horizontalSpacing) / (cellWidth + horizontalSpacing))
}

func widthOfGrid(
	columns: Int,
	cellWidth: CGFloat,
	spacing: CGFloat
) -> CGFloat {
	cellWidth * .init(columns) + spacing * .init(columns - 1)
}

func heightOfGrid(
	columns: Int,
	numberOfCells: Int,
	cellHeight: CGFloat,
	spacing: CGFloat
) -> CGFloat {
	let count = CGFloat(
		numberOfCells / columns + min(numberOfCells % columns, 1)
	)
	return cellHeight * count + spacing * (count - 1)
}

func slugify(_ string: String, delimiter: String = "-") -> String {
	string
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
}

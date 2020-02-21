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

func popUpWithAnimation(body: () -> Void) {
	withAnimation(.easeIn(duration: 0.15), body)
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

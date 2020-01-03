import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

let auth = Auth.auth()
let firestore = Firestore.firestore()
let storage = Storage.storage().reference()

let SCREEN_SIZE = UIScreen.main.bounds

var currentViewController: UIViewController! {
	UIApplication.shared.windows.last?.rootViewController
}

func popUpWithAnimation(body: () -> Void) {
	withAnimation(.easeIn(duration: 0.15), body)
}

func playHaptic(
	_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium,
	handler: (UIImpactFeedbackGenerator) -> Void = { $0.impactOccurred() }
) {
	let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
	impactFeedbackGenerator.prepare()
	handler(impactFeedbackGenerator)
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

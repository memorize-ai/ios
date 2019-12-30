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
	handler: (UIImpactFeedbackGenerator) -> Void
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

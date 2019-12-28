import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

let auth = Auth.auth()
let firestore = Firestore.firestore()
let storage = Storage.storage().reference()

let SCREEN_SIZE = UIScreen.main.bounds

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

@discardableResult
func share(
	items: [Any],
	excludedActivityTypes: [UIActivity.ActivityType]? = nil
) -> Bool {
	guard let source = UIApplication.shared.windows.last?.rootViewController else {
		return false
	}
	let vc = UIActivityViewController(
		activityItems: items,
		applicationActivities: nil
	)
	vc.excludedActivityTypes = excludedActivityTypes
	vc.popoverPresentationController?.sourceView = source.view
	source.present(vc, animated: true)
	return true
}

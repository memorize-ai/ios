import SwiftUI

struct ShareView: UIViewControllerRepresentable {
	final class ActivityViewController: UIViewController {
		func share(
			items: [Any],
			excludedActivityTypes: [UIActivity.ActivityType]?
		) {
			let vc = UIActivityViewController(
				activityItems: items,
				applicationActivities: nil
			)
			vc.excludedActivityTypes = excludedActivityTypes
			vc.popoverPresentationController?.sourceView = view
			present(vc, animated: true)
		}
	}
	
	let activityViewController = ActivityViewController()
	
	func makeUIViewController(context: Context) -> ActivityViewController {
		activityViewController
	}
	
	func updateUIViewController(
		_ uiViewController: ActivityViewController,
		context: Context
	) {}
	
	func share(
		items: [Any],
		excludedActivityTypes: [UIActivity.ActivityType]? = nil
	) {
		activityViewController.share(
			items: items,
			excludedActivityTypes: excludedActivityTypes
		)
	}
}

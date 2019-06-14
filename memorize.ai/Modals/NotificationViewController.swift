import UIKit

class NotificationViewController: UIViewController {
	@IBOutlet weak var notificationView: UIView!
	@IBOutlet weak var notificationLabel: UILabel!
	@IBOutlet weak var notificationLabelBottomConstraint: NSLayoutConstraint!
	
	func show(_ delay: TimeInterval, completion: (() -> Void)?) {
		notificationLabelBottomConstraint.constant = view.safeAreaInsets.bottom + 15
		view.layoutIfNeeded()
		notificationView.transform = CGAffineTransform(translationX: 0, y: notificationView.bounds.height)
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
			self.notificationView.transform = .identity
		}) {
			guard $0 else { return }
			Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
					self.notificationView.transform = CGAffineTransform(translationX: 0, y: self.notificationView.bounds.height)
				}) {
					guard $0 else { return }
					self.view.removeFromSuperview()
					completion?()
				}
			}
		}
	}
}

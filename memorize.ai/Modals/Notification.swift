import UIKit

extension UIViewController {
	func showNotification(_ text: String, type: NotificationType, delay: TimeInterval = 2, completion: (() -> Void)? = nil) {
		guard let notificationVC = storyboard?.instantiateViewController(withIdentifier: "notification") as? NotificationViewController else { return }
		addChild(notificationVC)
		notificationVC.view.frame = view.frame
		view.addSubview(notificationVC.view)
		notificationVC.didMove(toParent: self)
		notificationVC.notificationView.backgroundColor = type.color
		notificationVC.notificationLabel.text = text
		notificationVC.show(delay, completion: completion)
	}
}

enum NotificationType {
	case success
	case error
	case normal
	
	var color: UIColor {
		switch self {
		case .success:
			return #colorLiteral(red: 0.2539775372, green: 0.7368414402, blue: 0.4615401626, alpha: 1)
		case .error:
			return #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
		case .normal:
			return #colorLiteral(red: 0.3607843137, green: 0.3607843137, blue: 0.3607843137, alpha: 1)
		}
	}
}

import UIKit

class Notification {
	private static var pending: ((UIViewController) -> Void)?
	
	static func handleNotification(_ data: [AnyHashable : Any]) {
		guard let currentViewController = currentViewController, let type = data["type"] as? String else { return }
		switch type {
		case "cards-due":
			
		default:
			return
		}
	}
	
	static func callPendingNotification(_ viewController: UIViewController) {
		pending?(viewController)
		pending = nil
	}
}

import UIKit

class Notification {
	static func handle(_ data: [AnyHashable : Any]) {
		guard let currentViewController = currentViewController, let type = data["type"] as? String else { return }
		switch type {
		case "cards-due":
			return
		case "new-follower", "unfollowed":
			return //$ Show user profile
		case "reputation-milestone":
			return //$ Show reputation milestone modal
		default:
			return
		}
	}
}

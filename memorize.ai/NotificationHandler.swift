class Notification {
	static func handle(_ data: [AnyHashable : Any]) {
		guard let currentViewController = currentViewController, let type = data["type"] as? String else { return }
		switch type {
		case "cards-due":
			return
		case "new-follower", "unfollowed":
			guard let uid = data["uid"] as? String else { return currentViewController.showNotification("Unable to show user profile", type: .error) }
			UserViewController.show(currentViewController, id: uid)
		case "reputation-milestone":
			return //$ Show reputation milestone modal
		default:
			return
		}
	}
}

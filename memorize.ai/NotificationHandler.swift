import CFAlertViewController

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
			guard let amount = data["amount"] as? Int else { return }
			let alertController = CFAlertViewController(
				title: "You hit \(amount) reputation!",
				message: "Congratulations",
				textAlignment: .left,
				preferredStyle: .alert,
				didDismissAlertHandler: nil
			)
			alertController.addAction(CFAlertAction(
				title: "YOUR PROFILE", style: .Default,
				alignment: .justified,
				backgroundColor: UIColor(red: 46.0 / 255.0, green: 204.0 / 255.0, blue: 113.0 / 255.0, alpha: 1),
				textColor: nil
			) { _ in
				//$ Show your profile
			})
			alertController.addAction(CFAlertAction(
				title: "CANCEL",
				style: .Cancel,
				alignment: .justified,
				backgroundColor: nil,
				textColor: nil,
				handler: nil
			))
			currentViewController.present(alertController, animated: true)
		default:
			return
		}
	}
}

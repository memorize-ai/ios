import UIKit

class UserViewController: UIViewController {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var offlineView: UIView!
	@IBOutlet weak var actionsTableView: UITableView!
	
	struct Action {
		let name: String
		let action: Selector
	}
	
	let actions = [
		[]
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if startup {
			loadingView.isHidden = false
			activityIndicator.startAnimating()
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				let managedContext = appDelegate.persistentContainer.viewContext
				let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
				do {
					let login = try managedContext.fetch(fetchRequest)
					if login.count == 1 {
						let localEmail = login[0].value(forKey: "email") as? String
						Auth.auth().signIn(withEmail: localEmail!, password: login[0].value(forKey: "password") as? String ?? "") { user, error in
							if error == nil {
								id = user?.user.uid
								ref.child("users/\(id!)/name").observeSingleEvent(of: .value) { snapshot in
									name = snapshot.value as? String
									self.navigationItem.title = name
									email = localEmail
									loadData()
									self.activityIndicator.stopAnimating()
									self.loadingView.isHidden = true
									self.createSignOutBarButtonItem()
								}
							} else if let error = error {
								switch error.localizedDescription {
								case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
									self.activityIndicator.stopAnimating()
									self.offlineView.isHidden = false
									self.navigationController?.isNavigationBarHidden = true
								default:
									self.showHomeVC()
								}
							}
						}
					} else {
						showHomeVC()
					}
				} catch {}
			}
		} else {
			createSignOutBarButtonItem()
		}
		navigationController?.navigationBar.tintColor = .white
		navigationItem.title = name
		navigationItem.setHidesBackButton(true, animated: true)
	}
}

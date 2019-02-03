import UIKit
import CoreData
import Firebase

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var offlineView: UIView!
	@IBOutlet weak var actionsTableView: UITableView!
	
	struct Action {
		let image: UIImage?
		let name: String
		let action: Selector?
	}
	
	let actions = [
		Action(image: nil, name: "Empty Action", action: nil)
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
									self.createSettingsBarButtonItem()
								}
							} else if let error = error {
								switch error.localizedDescription {
								case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
									self.activityIndicator.stopAnimating()
									self.offlineView.isHidden = false
									self.navigationController?.isNavigationBarHidden = true
								default:
									self.signIn()
								}
							}
						}
					} else {
						signIn()
					}
				} catch {}
			}
		} else {
			createSettingsBarButtonItem()
		}
		navigationController?.navigationBar.tintColor = .white
		navigationItem.title = name
		navigationItem.setHidesBackButton(true, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		actionsTableView.reloadData()
	}
	
	func signIn() {
		performSegue(withIdentifier: "signIn", sender: self)
	}
	
	func createSettingsBarButtonItem() {
		navigationItem.setLeftBarButton(UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settings)), animated: false)
	}
	
	@objc func settings() {
		// MARK: show settings
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return actions.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = actions[indexPath.section]
		cell.imageView?.image = element.image
		cell.textLabel?.text = element.name
		cell.accessoryView?.isHidden = element.action == nil
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let action = actions[indexPath.section].action else { return }
		performSelector(onMainThread: action, with: nil, waitUntilDone: false)
	}
}

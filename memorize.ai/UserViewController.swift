import UIKit
import CoreData
import Firebase

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var offlineView: UIView!
	@IBOutlet weak var retryButton: UIButton!
	@IBOutlet weak var actionsTableView: UITableView!
	
	struct Action {
		let image: UIImage?
		let name: String
		let action: Selector?
	}
	
	let actions = [Action(image: #imageLiteral(resourceName: "Decks"), name: "Decks", action: #selector(showDecks)), Action(image: #imageLiteral(resourceName: "Cards"), name: "Cards", action: #selector(showCards)), Action(image: #imageLiteral(resourceName: "Create"), name: "Create a deck", action: #selector(createDeck)), Action(image: #imageLiteral(resourceName: "Search"), name: "Search for a deck", action: #selector(searchDeck))]
	
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
								firestore.collection("users").document(id!).getDocument { snapshot, error in
									guard let snapshot = snapshot?.data() else { return }
									name = snapshot["name"] as? String ?? ""
									self.navigationController?.isNavigationBarHidden = false
									self.navigationItem.title = name
									email = localEmail
									self.activityIndicator.stopAnimating()
									self.loadingView.isHidden = true
									self.createSettingsBarButtonItem()
									startup = false
								}
							} else if let error = error {
								switch error.localizedDescription {
								case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
									self.activityIndicator.stopAnimating()
									self.offlineView.isHidden = false
									self.retryButton.isHidden = false
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
	
	@IBAction func retry() {
		offlineView.isHidden = true
		retryButton.isHidden = true
		viewDidLoad()
	}
	
	func signIn() {
		performSegue(withIdentifier: "signIn", sender: self)
	}
	
	func createSettingsBarButtonItem() {
		navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(settings)), animated: false)
	}
	
	@objc func settings() {
		performSegue(withIdentifier: "settings", sender: self)
	}
	
	@objc func showDecks() {
		performSegue(withIdentifier: "decks", sender: self)
	}
	
	@objc func showCards() {
		performSegue(withIdentifier: "cards", sender: self)
	}
	
	@objc func createDeck() {
		performSegue(withIdentifier: "createDeck", sender: self)
	}
	
	@objc func searchDeck() {
		performSegue(withIdentifier: "searchDeck", sender: self)
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
		switch element.name {
		case "Decks":
			let decksCount = decks.count
			cell.detailTextLabel?.text = "\(decksCount) deck\(decksCount == 1 ? "" : "s")"
		case "Cards":
			let cardsCount = decks.reduce(0) { result, deck in result + deck.cards.count }
			cell.detailTextLabel?.text = "\(cardsCount) card\(cardsCount == 1 ? "" : "s")"
		default:
			cell.detailTextLabel?.text = nil
		}
		cell.accessoryView?.isHidden = element.action == nil
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let action = actions[indexPath.section].action else { return }
		performSelector(onMainThread: action, with: nil, waitUntilDone: false)
	}
}

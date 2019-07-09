import UIKit

class DeckSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	class DeckSetting {
		let name: String
		let color: UIColor
		let action: (DeckSettingsViewController) -> (DeckSettingTableViewCell) -> Void
		var cell: DeckSettingTableViewCell?
		
		init(name: String, color: UIColor?, action: @escaping (DeckSettingsViewController) -> (DeckSettingTableViewCell) -> Void) {
			self.name = name
			self.color = color ?? .black
			self.action = action
		}
		
		func callAction(_ viewController: DeckSettingsViewController) {
			guard let cell = cell else { return }
			action(viewController)(cell)
		}
	}
	
	let deckSettings = [
		[
			DeckSetting(name: "Rate deck", color: nil, action: rateDeck),
			DeckSetting(name: "Force review", color: nil, action: forceReview)
		],
//		[
//			DeckSetting(name: "User permissions", color: nil, action: viewPermissions)
//		],
		[
			DeckSetting(name: "Analytics", color: #colorLiteral(red: 0.2539775372, green: 0.7368414402, blue: 0.4615401626, alpha: 1), action: viewAnalytics),
			DeckSetting(name: "Card ratings", color: nil, action: viewCardRatings),
			DeckSetting(name: "Visit page", color: nil, action: visitPage)
		],
		[
			DeckSetting(name: "Clear all data", color: nil, action: clearAllData),
			DeckSetting(name: "Remove deck", color: nil, action: removeDeck)
		],
		[
			DeckSetting(name: "Permanently delete deck", color: #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1), action: deleteDeck)
		]
	]
	var deck: Deck?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share)), animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCurrentViewController()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		guard let deck = deck else { return }
		if let rateDeckVC = segue.destination as? RateDeckViewController {
			rateDeckVC.deck = deck
		} else if let reviewVC = segue.destination as? ReviewViewController {
			reviewVC.previewDeck = deck.name
			reviewVC.previewCards = deck.cards
		} else if let deckPermissionsVC = segue.destination as? DeckPermissionsViewController {
			deckPermissionsVC.deck = deck
		} else if let deckAnalyticsVC = segue.destination as? DeckAnalyticsViewController {
			deckAnalyticsVC.deck = deck
		} else if let cardAnalyticsVC = segue.destination as? CardAnalyticsViewController {
			cardAnalyticsVC.deck = deck
		} else if let deckVC = segue.destination as? DeckViewController {
			deckVC.deck.id = deck.id
			deckVC.deck.hasImage = deck.hasImage
			deckVC.deck.image = deck.image
		}
	}
	
	var filteredDeckSettings: [[DeckSetting]] {
		switch deck?.role {
		case .some(.owner):
			return deckSettings
		default:
			return [deckSettings[0], deckSettings[1], deckSettings[2]]
		}
	}
	
	@objc
	func share() {
		if let deckId = deck?.id, let url = Deck.url(id: deckId) {
			let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
			activityVC.popoverPresentationController?.sourceView = view
			present(activityVC, animated: true, completion: nil)
		} else {
			showNotification("Unable to share deck. Please try again", type: .error)
		}
	}
	
	func rateDeck(_ cell: DeckSettingTableViewCell) {
		performSegue(withIdentifier: "rate", sender: self)
	}
	
	func forceReview(_ cell: DeckSettingTableViewCell) {
		performSegue(withIdentifier: "review", sender: self)
	}
	
	func viewPermissions(_ cell: DeckSettingTableViewCell) {
		performSegue(withIdentifier: "permissions", sender: self)
	}
	
	func viewAnalytics(_ cell: DeckSettingTableViewCell) {
		performSegue(withIdentifier: "analytics", sender: self)
	}
	
	func viewCardRatings(_ cell: DeckSettingTableViewCell) {
		performSegue(withIdentifier: "cardRatings", sender: self)
	}
	
	func visitPage(_ cell: DeckSettingTableViewCell) {
		performSegue(withIdentifier: "visit", sender: self)
	}
	
	func clearAllData(_ cell: DeckSettingTableViewCell) {
		guard let deck = deck else { return }
		let alertController = UIAlertController(title: "Are you sure?", message: "All progress for this deck will be deleted. This cannot be undone", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
			cell.startLoading()
			deck.clearAllData { error in
				cell.stopLoading()
				if error == nil {
					buzz()
					self.showNotification("Cleared data", type: .success)
				} else {
					self.showNotification("An unknown error occurred. Please try again", type: .error)
				}
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	func removeDeck(_ cell: DeckSettingTableViewCell) {
		guard let id = id, let deck = deck else { return }
		let alertController = UIAlertController(title: "Remove deck", message: "Your data is saved and will not be lost", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
			cell.startLoading()
			firestore.document("users/\(id)/decks/\(deck.id)").updateData(["hidden": true]) { error in
				cell.stopLoading()
				if error == nil {
					buzz()
					if decks.isEmpty {
						self.performSegue(withIdentifier: "home", sender: self)
					} else {
						self.navigationController?.popViewController(animated: true)
					}
				} else {
					self.showNotification("An unknown error occurred. Please try again", type: .error)
				}
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	func deleteDeck(_ cell: DeckSettingTableViewCell) {
		guard let id = id, let deck = deck else { return }
		let alertController = UIAlertController(title: "Are you sure?", message: "This deck will be permanently deleted from the marketplace. Anyone using it will be unable to use it anymore. This action cannot be undone", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
			let alertController = UIAlertController(title: "Are you really sure?", message: "This action cannot be undone", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
				cell.startLoading()
				Deck.delete(deck.id) { error in
					if error == nil {
						Listener.remove("decks/\(deck.id)")
						Listener.remove("decks/\(deck.id)/cards")
						storage.child("decks/\(deck.id)").delete { error in
							firestore.document("users/\(id)/decks/\(deck.id)").delete { error in
								cell.stopLoading()
								if error == nil {
									buzz()
									Listener.remove("users/\(id)/decks/\(deck.id)")
									if decks.isEmpty {
										self.performSegue(withIdentifier: "home", sender: self)
									} else {
										self.navigationController?.popViewController(animated: true)
									}
								} else {
									self.showNotification("An unknown error occurred. Please try again", type: .error)
								}
							}
						}
					} else {
						self.showNotification("An unknown error occurred. Please try again", type: .error)
					}
				}
			})
			self.present(alertController, animated: true, completion: nil)
		})
		present(alertController, animated: true, completion: nil)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return filteredDeckSettings.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredDeckSettings[section].count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? DeckSettingTableViewCell else { return _cell }
		let element = filteredDeckSettings[indexPath.section][indexPath.row]
		cell.label.text = element.name
		cell.label.textColor = element.color
		element.cell = cell
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let element = filteredDeckSettings[indexPath.section][indexPath.row]
		if element.cell?.activityIndicator.isAnimating ?? true { return }
		element.callAction(self)
	}
}

class DeckSettingTableViewCell: UITableViewCell {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	func startLoading() {
		activityIndicator.startAnimating()
	}
	
	func stopLoading() {
		activityIndicator.stopAnimating()
	}
}

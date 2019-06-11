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
		DeckSetting(name: "Clear all data", color: nil, action: clearAllData),
		DeckSetting(name: "Remove deck", color: nil, action: removeDeck),
		DeckSetting(name: "Permanently delete deck", color: .red, action: deleteDeck)
	]
	var deck: Deck?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	var filteredDeckSettings: [DeckSetting] {
		switch deck?.role {
		case .some(.owner):
			return deckSettings
		default:
			return [deckSettings[0], deckSettings[1]]
		}
	}
	
	func clearAllData(_ cell: DeckSettingTableViewCell) {
		guard let deck = deck else { return }
		let alertController = UIAlertController(title: "Are you sure?", message: "All progress for this deck will be deleted. This cannot be undone", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Clear", style: .default) { _ in
			deck.clearAllData { error in
				if error == nil {
					cell.activityIndicator.stopAnimating()
					buzz()
				} else {
					cell.activityIndicator.stopAnimating()
					self.showAlert("An unknown error occurred. Please try again")
				}
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	func removeDeck(_ cell: DeckSettingTableViewCell) {
		guard let deck = deck else { return }
		firestore.document("decks/\(deck.id)").updateData(["hidden": true]) { error in
			if error == nil {
				cell.activityIndicator.stopAnimating()
				buzz()
				self.navigationController?.popViewController(animated: true)
			} else {
				cell.activityIndicator.stopAnimating()
				self.showAlert("An unknown error occurred. Please try again")
			}
		}
	}
	
	func deleteDeck(_ cell: DeckSettingTableViewCell) {
		guard let deck = deck else { return }
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredDeckSettings.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? DeckSettingTableViewCell else { return _cell }
		let element = filteredDeckSettings[indexPath.row]
		cell.label.text = element.name
		cell.label.textColor = element.color
		element.cell = cell
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		filteredDeckSettings[indexPath.row].callAction(self)
	}
}

class DeckSettingTableViewCell: UITableViewCell {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}

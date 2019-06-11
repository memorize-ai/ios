import UIKit

class DeckSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	class DeckSetting {
		let name: String
		let color: UIColor
		let action: (DeckSettingsViewController) -> () -> Void
		
		init(name: String, color: UIColor?, action: @escaping (DeckSettingsViewController) -> () -> Void) {
			self.name = name
			self.color = color ?? .black
			self.action = action
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
	
	func clearAllData() {
		let alertController = UIAlertController(title: "Are you sure?", message: "All progress for this deck will be deleted. This cannot be undone", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Clear", style: .default) { _ in
			self.deck?.clearAllData { error in
				if error == nil {
					
				} else {
					self.showAlert("An unknown error occurred. Please try again")
				}
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	func removeDeck() {
		
	}
	
	func deleteDeck() {
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredDeckSettings.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = filteredDeckSettings[indexPath.row]
		cell.textLabel?.text = element.name
		cell.textLabel?.textColor = element.color
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		filteredDeckSettings[indexPath.row].action(self)()
	}
}

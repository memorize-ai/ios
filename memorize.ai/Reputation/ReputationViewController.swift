import UIKit

class ReputationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var reputationHistoryTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if ReputationHistoryItem.shouldLoad {
			ReputationHistoryItem.shouldLoad = false
			ReputationHistoryItem.loadAll()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .reputationHistoryAdded || change == .reputationHistoryModified || change == .reputationHistoryRemoved {
				self.reputationHistoryTableView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return reputationHistory.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return reputationHistory[section].date.formatCompact()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return reputationHistory[section].items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? ReputationHistoryTableViewCell else { return _cell }
		let historyItem = reputationHistory[indexPath.section].items[indexPath.row]
		let amountIsNegative = historyItem.amount < 0
		cell.amountLabel.text = "\(amountIsNegative ? "-" : "+")\(abs(historyItem.amount).formattedWithCommas)"
		cell.amountLabel.textColor = amountIsNegative ? #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1) : #colorLiteral(red: 0.2823529412, green: 0.8, blue: 0.4980392157, alpha: 1)
		cell.descriptionLabel.text = historyItem.description
		cell.afterLabel.text = historyItem.after.formattedWithCommas
		cell.editingAccessoryType = historyItem.uid == nil && historyItem.deckId == nil ? .none : .disclosureIndicator
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let historyItem = reputationHistory[indexPath.section].items[indexPath.row]
		if let uid = historyItem.uid {
			print(uid) //$ Show user's profile
		} else if let deckId = historyItem.deckId {
			if let deck = Deck.get(deckId) {
				DeckViewController.show(self, id: deckId, hasImage: deck.hasImage, image: deck.image)
			} else {
				firestore.document("decks/\(deckId)").getDocument { snapshot, error in
					guard error == nil, let snapshot = snapshot else { return self.showNotification("Unable to view deck. Please try again", type: .error) }
					DeckViewController.show(self, id: deckId, hasImage: snapshot.get("hasImage") as? Bool ?? false)
				}
			}
		}
	}
}

class ReputationHistoryTableViewCell: UITableViewCell {
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var afterLabel: UILabel!
}

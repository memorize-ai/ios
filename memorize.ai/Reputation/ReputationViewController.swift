import UIKit

fileprivate var shouldLoadReputationHistory = true

class ReputationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var reputationHistoryTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if shouldLoadReputationHistory {
			shouldLoadReputationHistory = false
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
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return reputationHistory[section].items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? ReputationHistoryTableViewCell else { return _cell }
		let historyItem = reputationHistory[indexPath.section].items[indexPath.row]
		let amountIsNegative = historyItem.amount < 0
		cell.amountLabel.text = "\(amountIsNegative ? "-" : "+")\(historyItem.amount.formattedWithCommas)"
		cell.amountLabel.textColor = amountIsNegative ? #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1) : #colorLiteral(red: 0.2823529412, green: 0.8, blue: 0.4980392157, alpha: 1)
		cell.descriptionLabel.text = historyItem.description
		cell.afterLabel.text = historyItem.after.formattedWithCommas
		cell.editingAccessoryType = historyItem.uid == nil && historyItem.deckId == nil ? .none : .disclosureIndicator
		return cell
	}
}

class ReputationHistoryTableViewCell: UITableViewCell {
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var afterLabel: UILabel!
}

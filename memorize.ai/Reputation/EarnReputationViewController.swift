import UIKit

class EarnReputationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var reputationTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if ReputationValue.shouldLoad {
			ReputationValue.shouldLoad = false
			ReputationValue.loadAll()
		}
		reputationTableView.tableFooterView = UIView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .reputationValueAdded || change == .reputationValueModified || change == .reputationValueRemoved {
				self.reputationTableView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return reputationValues.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? EarnReputationTableViewCell else { return _cell }
		let reputationValue = reputationValues[indexPath.row]
		let amountIsNegative = reputationValue.amount < 0
		cell.amountLabel.text = "\(amountIsNegative ? "-" : "+")\(abs(reputationValue.amount).formattedWithCommas)"
		cell.amountLabel.textColor = amountIsNegative ? #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1) : #colorLiteral(red: 0.2823529412, green: 0.8, blue: 0.4980392157, alpha: 1)
		cell.descriptionLabel.text = reputationValue.description
		return cell
	}
}

class EarnReputationTableViewCell: UITableViewCell {
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
}

import UIKit

fileprivate var shouldLoadReputationValues = true

class EarnReputationViewController: UIViewController {
	@IBOutlet weak var reputationTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if shouldLoadReputationValues {
			shouldLoadReputationValues = false
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
}

class EarnReputationTableViewCell: UITableViewCell {
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
}

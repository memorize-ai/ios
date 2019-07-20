import UIKit

class ReputationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var reputationHistoryTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		<#code#>
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		<#code#>
	}
}

class ReputationHistoryTableViewCell: UITableViewCell {
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var afterLabel: UILabel!
}

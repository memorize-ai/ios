import UIKit

class SearchDeckViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var decksTableView: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text else { return }
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		<#code#>
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		<#code#>
	}
}

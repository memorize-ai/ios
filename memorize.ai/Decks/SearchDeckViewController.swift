import UIKit
import InstantSearchClient

class SearchDeckViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var decksTableView: UITableView!
	
	struct SearchResult {
		let id: String
		let name: String
	}
	
	var result = [SearchResult]()
	
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
	
	@IBAction func back() {
		navigationController?.popViewController(animated: true)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		decksIndex.search(Query(query: searchText)) { content, error in
			if let content = content, error == nil {
				self.result.removeAll()
				for deck in content {
					self.result.append(SearchResult(id: deck["id"], name: <#T##String#>))
				}
				self.decksTableView.reloadData()
			} else if let error = error {
				self.showAlert(error.localizedDescription)
			}
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return result.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = result[indexPath.row]
		storage.child("decks/\(element.id)").getData(maxSize: 50000000) { data, error in
			if let data = data, error == nil {
				cell.imageView?.image = UIImage(data: data)
			} else {
				cell.imageView?.image = #imageLiteral(resourceName: "Gray Deck")
			}
		}
		cell.textLabel?.text = element.name
		return cell
	}
}

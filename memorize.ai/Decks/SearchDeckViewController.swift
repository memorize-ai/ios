import UIKit
import InstantSearchClient

class SearchDeckViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var decksTableView: UITableView!
	
	struct SearchResult {
		let id: String
		let name: String
		var owner: String?
	}
	
	var result = [SearchResult]()
	var selectedResult: SearchResult?
	
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let deckVC = segue.destination as? DeckViewController, let deckId = selectedResult?.id else { return }
		deckVC.deckId = deckId
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		result.removeAll()
		if searchText.trim().isEmpty {
			decksTableView.reloadData()
		} else {
			decksIndex.search(Query(query: searchText)) { content, error in
				if let hits = content?["hits"] as? [[String: Any]], error == nil {
					self.result = hits.map {
						let resultId = $0["objectID"] as? String ?? ""
						firestore.collection("users").document($0["owner"] as? String ?? "").getDocument { snapshot, error in
							guard let snapshot = snapshot?.data(), error == nil else { return }
							for i in 0..<self.result.count {
								if self.result[i].id == resultId {
									self.result[i].owner = snapshot["name"] as? String
									self.decksTableView.reloadData()
								}
							}
						}
						return SearchResult(id: resultId, name: $0["name"] as? String ?? "", owner: nil)
					}
				} else if let error = error {
					self.showAlert(error.localizedDescription)
				}
				self.decksTableView.reloadData()
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
			tableView.reloadData()
		}
		cell.textLabel?.text = element.name
		cell.detailTextLabel?.text = element.owner
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedResult = result[indexPath.row]
		performSegue(withIdentifier: "deck", sender: self)
	}
}

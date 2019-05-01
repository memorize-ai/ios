import UIKit
import InstantSearchClient

class SearchDeckViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var decksTableView: UITableView!
	
	class SearchResult {
		let id: String
		var image: UIImage?
		let name: String
		let owner: String
		
		init(id: String, image: UIImage?, name: String, owner: String) {
			self.id = id
			self.image = image
			self.name = name
			self.owner = owner
		}
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
		guard let deckVC = segue.destination as? DeckViewController, let selectedResult = selectedResult else { return }
		deckVC.deckId = selectedResult.id
		deckVC.image = selectedResult.image
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		result.removeAll()
		if searchText.trim().isEmpty {
			decksTableView.reloadData()
		} else {
			decksIndex.search(Query(query: searchText)) { content, error in
				if error == nil, let hits = content?["hits"] as? [[String : Any]] {
					hits.forEach { hit in
						let deckId = hit["objectID"] as? String ?? "Error"
						firestore.document("decks/\(deckId)").addSnapshotListener { _, error in
							guard error == nil, let owner = hit["owner"] as? String else { return }
							firestore.document("users/\(owner)").addSnapshotListener { snapshot, userError in
								guard userError == nil, let snapshot = snapshot else { return }
								self.result.append(SearchResult(id: deckId, image: nil, name: hit["name"] as? String ?? "Error", owner: snapshot.get("name") as? String ?? "Error"))
								self.decksTableView.reloadData()
							}
						}
					}
				} else if let error = error {
					self.showAlert(error.localizedDescription)
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return result.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = result[indexPath.row]
		if let image = element.image {
			cell.imageView?.image = image
		} else {
			storage.child("decks/\(element.id)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				element.image = image
				tableView.reloadData()
			}
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

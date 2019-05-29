import UIKit
import InstantSearchClient

class SearchDeckViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var decksCollectionView: UICollectionView!
	
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
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.minimumLineSpacing = 8
		flowLayout.itemSize = CGSize(width: view.bounds.width - 16, height: 50)
		decksCollectionView.collectionViewLayout = flowLayout
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
		super.prepare(for: segue, sender: sender)
		guard let deckVC = segue.destination as? DeckViewController, let selectedResult = selectedResult else { return }
		deckVC.deckId = selectedResult.id
		deckVC.image = selectedResult.image
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		result.removeAll()
		decksCollectionView.reloadData()
		if !searchText.trim().isEmpty {
			decksIndex.search(Query(query: searchText)) { content, error in
				if error == nil, let hits = content?["hits"] as? [[String : Any]] {
					hits.forEach { hit in
						let deckId = hit["objectID"] as? String ?? "Error"
						firestore.document("decks/\(deckId)").addSnapshotListener { _, error in
							guard error == nil, let owner = hit["owner"] as? String else { return }
							firestore.document("users/\(owner)").addSnapshotListener { snapshot, userError in
								guard userError == nil, let snapshot = snapshot else { return }
								self.result.append(SearchResult(id: deckId, image: nil, name: hit["name"] as? String ?? "Error", owner: snapshot.get("name") as? String ?? "Error"))
								self.decksCollectionView.reloadData()
								Timer.scheduledTimer(withTimeInterval: 0.02, repeats: false) { _ in
									self.decksCollectionView.reloadData()
								}
							}
						}
					}
				} else if let error = error {
					self.showAlert(error.localizedDescription)
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return result.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchResultCollectionViewCell
		let element = result[indexPath.item]
		if let image = element.image {
			cell.imageView.image = image
		} else {
			storage.child("decks/\(element.id)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				cell.imageView.image = image
				element.image = image
			}
		}
		cell.nameLabel.text = element.name
		cell.ownerLabel.text = element.owner
		cell.owned(Deck.get(element.id) != nil)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedResult = result[indexPath.item]
		performSegue(withIdentifier: "deck", sender: self)
	}
}

class SearchResultCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var ownerLabel: UILabel!
	@IBOutlet weak var checkImageView: UIImageView!
	
	func owned(_ isOwned: Bool) {
		checkImageView.isHidden = !isOwned
	}
}

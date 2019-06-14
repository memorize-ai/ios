import UIKit
import InstantSearchClient
import WebKit

class SearchDeckViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var decksCollectionView: UICollectionView!
	
	class SearchResult {
		let id: String
		var image: UIImage?
		let name: String
		let subtitle: String
		let averageRating: Double
		let ratingsCount: Int
		
		init(id: String, image: UIImage?, name: String, subtitle: String, averageRating: Double, ratingsCount: Int) {
			self.id = id
			self.image = image
			self.name = name
			self.subtitle = subtitle
			self.averageRating = averageRating
			self.ratingsCount = ratingsCount
		}
	}
	
	var searchResults = [SearchResult]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.minimumLineSpacing = 20
		let size = view.bounds.width - 40
		flowLayout.itemSize = CGSize(width: size, height: size)
		decksCollectionView.collectionViewLayout = flowLayout
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: true)
		updateCurrentViewController()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		guard let deckVC = segue.destination as? DeckViewController, let selectedResult = sender as? SearchResult else { return }
		deckVC.deckId = selectedResult.id
		deckVC.image = selectedResult.image
	}
	
	@IBAction func back() {
		navigationController?.popViewController(animated: true)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchResults.removeAll()
		decksCollectionView.reloadData()
		if !searchText.trim().isEmpty {
			Algolia.search(.decks, for: searchText) { results, error in
				if error == nil {
					results.forEach { result in
						let deckId = result["objectID"] as? String ?? "Error"
						listeners["decks/\(deckId)"] = firestore.document("decks/\(deckId)").addSnapshotListener { _, error in
							guard error == nil, let owner = result["owner"] as? String else { return }
							listeners["users/\(owner)"] = firestore.document("users/\(owner)").addSnapshotListener { snapshot, userError in
								guard userError == nil, let snapshot = snapshot, let ratings = snapshot.get("ratings") as? [String : Any] else { return }
								self.searchResults.append(SearchResult(
									id: deckId,
									image: Deck.get(deckId)?.image,
									name: result["name"] as? String ?? "Error",
									subtitle: snapshot.get("subtitle") as? String ?? "Error",
									averageRating: ratings["average"] as? Double ?? 0,
									ratingsCount: (ratings["1"] as? Int ?? 0) + (ratings["2"] as? Int ?? 0) + (ratings["3"] as? Int ?? 0) + (ratings["4"] as? Int ?? 0) + (ratings["5"] as? Int ?? 0)
								))
								self.decksCollectionView.reloadData()
							}
						}
					}
				} else {
					self.showNotification("Unable to load search results. Please try again", type: .error)
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return searchResults.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? SearchResultCollectionViewCell else { return _cell }
		let searchResult = searchResults[indexPath.item]
		if let image = searchResult.image {
			cell.imageView.image = image
		} else {
			storage.child("decks/\(searchResult.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				cell.imageView.image = image
				searchResult.image = image
				Deck.get(searchResult.id)?.image = image
			}
		}
		cell.nameLabel.text = searchResult.name
		cell.subtitleLabel.text = searchResult.subtitle
		cell.setAverageRating(searchResult.averageRating)
		cell.ratingsCountLabel.text = String(searchResult.ratingsCount)
		// Load webview as well
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		performSegue(withIdentifier: "deck", sender: searchResults[indexPath.item])
	}
}

class SearchResultCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	@IBOutlet weak var starsSliderView: UIView!
	@IBOutlet weak var starsSliderViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingsCountLabel: UILabel!
	@IBOutlet weak var card1WebView: WKWebView!
	@IBOutlet weak var card2WebView: WKWebView!
	@IBOutlet weak var card3WebView: WKWebView!
	
	func setAverageRating(_ rating: Double) {
		starsSliderViewTrailingConstraint.constant = starsSliderView.bounds.width * (rating == 0 ? 1 : CGFloat(5 - rating) / 5)
		layoutIfNeeded()
	}
}

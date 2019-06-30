import UIKit
import InstantSearchClient

class SearchDeckViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var decksCollectionView: UICollectionView!
	
	class SearchResult {
		let id: String
		let hasImage: Bool
		var image: UIImage?
		let name: String
		let subtitle: String
		let ratings: DeckRatings
		let deck: Deck?
		
		init(id: String, hasImage: Bool, image: UIImage?, name: String, subtitle: String, ratings: DeckRatings, deck: Deck?) {
			self.id = id
			self.hasImage = hasImage
			self.image = image
			self.name = name
			self.subtitle = subtitle
			self.ratings = ratings
			self.deck = deck
		}
	}
	
	let SEARCH_RESULT_CELL_HEIGHT: CGFloat = 75
	
	var searchOperation: Operation?
	var searchResults = [SearchResult]()
	var cache = [String : SearchResult]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: view.bounds.width - 40, height: SEARCH_RESULT_CELL_HEIGHT)
		flowLayout.minimumLineSpacing = 30
		decksCollectionView.collectionViewLayout = flowLayout
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update(nil)
		decksCollectionView.reloadData()
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
		deckVC.deck.id = selectedResult.id
		deckVC.deck.hasImage = selectedResult.hasImage
		deckVC.deck.image = selectedResult.image
	}
	
	@IBAction
	func back() {
		navigationController?.popViewController(animated: true)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchOperation?.cancel()
		searchResults.removeAll()
		if searchText.trim().isEmpty {
			decksCollectionView.reloadData()
		} else {
			searchOperation = Algolia.search(.decks, for: searchText) { results, error in
				if error == nil {
					for result in results {
						guard let deckId = Algolia.id(result: result) else { continue }
						if let cachedResult = self.cache[deckId] {
							self.searchResults.append(cachedResult)
							self.decksCollectionView.reloadData()
						} else {
							listeners["decks/\(deckId)"] = firestore.document("decks/\(deckId)").addSnapshotListener { snapshot, error in
								guard error == nil, let snapshot = snapshot else { return }
								let deck = Deck.get(deckId)
								let newSearchResult = SearchResult(
									id: deckId,
									hasImage: snapshot.get("hasImage") as? Bool ?? false,
									image: deck?.image,
									name: snapshot.get("name") as? String ?? "Error",
									subtitle: snapshot.get("subtitle") as? String ?? "Error",
									ratings: DeckRatings(snapshot),
									deck: deck
								)
								if let searchResultIndex = self.indexOfSearchResult(deckId) {
									self.searchResults[searchResultIndex] = newSearchResult
								} else {
									self.searchResults.append(newSearchResult)
								}
								self.cache[deckId] = newSearchResult
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
	
	func indexOfSearchResult(_ id: String) -> Int? {
		for i in 0..<searchResults.count {
			if searchResults[i].id == id {
				return i
			}
		}
		return nil
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return searchResults.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? SearchResultCollectionViewCell else { return _cell }
		let searchResult = searchResults[indexPath.item]
		if let image = searchResult.image {
			cell.setLoading(false)
			cell.imageView.image = image
		} else if searchResult.hasImage {
			cell.setLoading(true)
			storage.child("decks/\(searchResult.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				cell.setLoading(false)
				cell.imageView.image = image
				searchResult.image = image
				searchResult.deck?.image = image
				self.decksCollectionView.reloadData()
			}
		} else {
			cell.setLoading(false)
			cell.imageView.image = DEFAULT_DECK_IMAGE
			searchResult.image = DEFAULT_DECK_IMAGE
			searchResult.deck?.image = nil
		}
		cell.nameLabel.text = searchResult.name
		cell.subtitleLabel.text = searchResult.subtitle
		cell.setAverageRating(searchResult.ratings.average)
		cell.ratingsCountLabel.text = String(searchResult.ratings.count)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		performSegue(withIdentifier: "deck", sender: searchResults[indexPath.item])
	}
}

class SearchResultCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	@IBOutlet weak var starsSliderView: UIView!
	@IBOutlet weak var starsSliderViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingsCountLabel: UILabel!
	
	func setAverageRating(_ rating: Double) {
		starsSliderViewTrailingConstraint.constant = starsSliderView.bounds.width * (rating == 0 ? 1 : CGFloat(5 - rating) / 5)
		layoutIfNeeded()
	}
	
	func setLoading(_ isLoading: Bool) {
		imageView.layer.borderWidth = isLoading ? 1 : 0
		if isLoading {
			imageView.layer.borderColor = UIColor.lightGray.cgColor
			imageActivityIndicator.startAnimating()
		} else {
			imageActivityIndicator.stopAnimating()
		}
	}
}

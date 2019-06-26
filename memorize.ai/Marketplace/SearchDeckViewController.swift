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
		let ratings: DeckRatings
		let deck: Deck?
		
		init(id: String, image: UIImage?, name: String, subtitle: String, ratings: DeckRatings, deck: Deck?) {
			self.id = id
			self.image = image
			self.name = name
			self.subtitle = subtitle
			self.ratings = ratings
			self.deck = deck
		}
	}
	
	var searchOperation: Operation?
	var searchResults = [SearchResult]()
	var cache = [String : SearchResult]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.minimumLineSpacing = 20
		let size = view.bounds.width - 40
		flowLayout.itemSize = CGSize(width: size, height: 10.5 * size / 12)
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
		deckVC.deck.id = selectedResult.id
		deckVC.deck.image = selectedResult.image
	}
	
	@IBAction
	func back() {
		navigationController?.popViewController(animated: true)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchResults.removeAll()
		if searchText.trim().isEmpty {
			decksCollectionView.reloadData()
		} else {
			searchOperation?.cancel()
			searchOperation = Algolia.search(.decks, for: searchText) { results, error in
				if error == nil {
					for result in results {
						guard let deckId = result["objectID"] as? String else { continue }
						if let cachedResult = self.cache[deckId] {
							self.searchResults.append(cachedResult)
							self.decksCollectionView.reloadData()
						} else {
							listeners["decks/\(deckId)"] = firestore.document("decks/\(deckId)").addSnapshotListener { _, error in
								guard error == nil, let owner = result["owner"] as? String else { return }
								listeners["users/\(owner)"] = firestore.document("users/\(owner)").addSnapshotListener { snapshot, userError in
									guard userError == nil, let snapshot = snapshot else { return }
									let deck = Deck.get(deckId)
									let searchResult = SearchResult(
										id: deckId,
										image: deck?.image,
										name: result["name"] as? String ?? "Error",
										subtitle: snapshot.get("subtitle") as? String ?? "Error",
										ratings: DeckRatings(snapshot),
										deck: deck
									)
									self.searchResults.append(searchResult)
									self.decksCollectionView.reloadData()
									self.cache[deckId] = searchResult
								}
							}
						}
					}
					self.decksCollectionView.reloadData()
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
				searchResult.deck?.image = image
				self.decksCollectionView.reloadData()
			}
		}
		cell.nameLabel.text = searchResult.name
		cell.subtitleLabel.text = searchResult.subtitle
		cell.setAverageRating(searchResult.ratings.average)
		cell.ratingsCountLabel.text = String(searchResult.ratings.count)
		if let deck = searchResult.deck {
			let cards = deck.cards.sorted { $0.likes > $1.likes }.prefix(3)
			for i in 0..<cards.count {
				cell.load(cell.webViews[i], text: cards[i].front)
			}
		} else {
			firestore.collection("decks/\(searchResult.id)/cards").order(by: "likes").limit(to: 3).getDocuments { snapshot, error in
				guard error == nil, let snapshot = snapshot?.documents else { return }
				for i in 0..<snapshot.count {
					cell.load(cell.webViews[i], text: snapshot[i].get("front") as? String ?? "")
				}
			}
		}
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
	
	var webViews: [WKWebView] {
		return [card1WebView, card2WebView, card3WebView]
	}
	
	func setAverageRating(_ rating: Double) {
		starsSliderViewTrailingConstraint.constant = starsSliderView.bounds.width * (rating == 0 ? 1 : CGFloat(5 - rating) / 5)
		layoutIfNeeded()
	}
	
	func load(_ webView: WKWebView, text: String) {
		webView.render(text, fontSize: 50, textColor: "000000", backgroundColor: "ffffff")
	}
}

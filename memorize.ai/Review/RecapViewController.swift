import UIKit
import WebKit

class RecapViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var recapCollectionView: UICollectionView!
	
	var cards = [(id: String, deck: Deck, card: Card, rating: PerformanceRating, next: Date?)]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: view.bounds.width - 16, height: 68)
		flowLayout.sectionInset.top = 8
		recapCollectionView.collectionViewLayout = flowLayout
		navigationItem.setHidesBackButton(true, animated: true)
		let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(back))
		navigationItem.setRightBarButton(done, animated: true)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .cardModified {
				self.recapCollectionView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	@objc
	func back() {
		performSegue(withIdentifier: "done", sender: self)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cards.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? RecapCollectionViewCell else { return _cell }
		let element = cards[indexPath.item]
		if let image = element.deck.image {
			cell.imageView.image = image
		} else if element.deck.hasImage {
			storage.child("decks/\(element.deck.id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
				guard error == nil, let data = data, let image = UIImage(data: data) else { return }
				element.deck.image = image
				cell.imageView.image = image
				self.recapCollectionView.reloadData()
			}
		} else {
			element.deck.image = nil
			cell.imageView.image = DEFAULT_DECK_IMAGE
		}
		cell.load(element.card.front)
		if let next = element.next {
			cell.nextLabel.text = next.format()
		} else if let id = id {
			cell.nextLabel.text = "Loading..."
			listeners["users/\(id)/decks/\(element.deck.id)/cards/\(element.card.id)/history/\(element.id)"] = firestore.document("users/\(id)/decks/\(element.deck.id)/cards/\(element.card.id)/history/\(element.id)").addSnapshotListener { snapshot, error in
				guard error == nil, let next = snapshot?.getDate("next") else { return }
				self.cards[indexPath.item] = (id: element.id, deck: element.deck, card: element.card, rating: element.rating, next: next)
				cell.nextLabel.text = next.format()
			}
		}
		cell.ratingImageView.image = element.rating.image
		return cell
	}
}

class RecapCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var nextLabel: UILabel!
	@IBOutlet weak var ratingImageView: UIImageView!
	
	func load(_ text: String) {
		label.text = text.clean()
	}
}

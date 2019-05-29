import UIKit
import Firebase
import WebKit

class DeckViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var mainView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var getButton: UIButton!
	@IBOutlet weak var getButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var getActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var previewButton: UIButton!
	@IBOutlet weak var descriptionWebView: WKWebView!
	@IBOutlet weak var descriptionWebViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var cardsCollectionView: UICollectionView!
	@IBOutlet weak var creatorLabel: UILabel!
	
	var deckId: String?
	var deckName: String?
	var count: Int?
	var image: UIImage?
	var cards = [Card]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: view.bounds.width - 40, height: 35)
		cardsCollectionView.collectionViewLayout = flowLayout
		imageView.layer.borderWidth = 0.5
		imageView.layer.borderColor = UIColor.lightGray.cgColor
		imageView.layer.masksToBounds = true
		guard let deckId = deckId else { return }
		firestore.document("decks/\(deckId)").addSnapshotListener { snapshot, error in
			if error == nil, let snapshot = snapshot {
				self.deckName = snapshot.get("name") as? String ?? "Error"
				self.nameLabel.text = self.deckName
				self.count = snapshot.get("count") as? Int
				self.load(snapshot.get("description") as? String ?? "An error has occurred")
				self.activityIndicator.stopAnimating()
				self.loadingView.isHidden = true
				firestore.document("users/\(snapshot.get("creator") as! String)").getDocument { creatorSnapshot, creatorError in
					guard creatorError == nil, let creatorSnapshot = creatorSnapshot else { return }
					self.creatorLabel.text = "Created by \(creatorSnapshot.get("name") as! String)"
					self.resizeDescriptionWebView()
				}
			} else {
				self.activityIndicator.stopAnimating()
				let alertController = UIAlertController(title: "Error", message: "Unable to load deck", preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
					self.navigationController?.popViewController(animated: true)
				})
				self.present(alertController, animated: true, completion: nil)
			}
		}
		firestore.collection("decks/\(deckId)/cards").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let card = $0.document
				let cardId = card.documentID
				switch $0.type {
				case .added:
					self.cards.append(Card(
						id: cardId,
						front: card.get("front") as? String ?? "Error",
						back: card.get("back") as? String ?? "Error",
						created: card.get("created") as? Date ?? Date(),
						updated: card.get("updated") as? Date ?? Date(),
						likes: card.get("likes") as? Int ?? 0,
						dislikes: card.get("dislikes") as? Int ?? 0,
						deck: deckId
					))
					self.reloadCards()
					ChangeHandler.call(.cardModified)
				case .modified:
					self.cards.first { return $0.id == cardId }?.update(card, type: .card)
					self.reloadCards()
					ChangeHandler.call(.cardModified)
				case .removed:
					self.cards = self.cards.filter { return $0.id != cardId }
					self.reloadCards()
					ChangeHandler.call(.cardRemoved)
				@unknown default:
					return
				}
			}
		}
		if let image = image {
			imageActivityIndicator.stopAnimating()
			imageView.image = image
			imageView.layer.borderWidth = 0
		} else {
			storage.child("decks/\(self.deckId!)").getData(maxSize: fileLimit) { data, error in
				self.imageActivityIndicator.stopAnimating()
				self.imageView.layer.borderWidth = 0
				if error == nil, let data = data {
					self.imageView.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
				} else {
					self.imageView.image = #imageLiteral(resourceName: "Gray Deck")
				}
			}
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		Deck.view(deckId!)
		previewButton.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
		if Deck.get(deckId!) != nil {
			getButtonWidthConstraint.constant = 90
			view.layoutIfNeeded()
			getButton.setTitle("DELETE", for: .normal)
			getButton.backgroundColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		resizeCardsCollectionView()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		guard let reviewVC = segue.destination as? ReviewViewController else { return }
		reviewVC.previewCards = cards
		reviewVC.previewDeck = deckName
	}
	
	@IBAction func preview() {
		switch count {
		case 0:
			showAlert("There are no cards in this deck to preview")
		case cards.count:
			performSegue(withIdentifier: "preview", sender: self)
		default:
			showAlert("Loading cards...")
		}
	}
	
	func load(_ text: String) {
		descriptionWebView.render(text, fontSize: 55, textColor: "000000", backgroundColor: "ffffff")
	}
	
	func resizeDescriptionWebView() {
		descriptionWebViewHeightConstraint.constant = view.bounds.height - mainView.bounds.height - creatorLabel.bounds.height - 190
		view.layoutIfNeeded()
	}
	
	func reloadCards() {
		cardsCollectionView.reloadData()
		resizeCardsCollectionView()
	}
	
	func resizeCardsCollectionView() {
		cardsCollectionView.frame.size = CGSize(width: view.bounds.width - 40, height: CGFloat(cards.count * 45))
	}
	
	@IBAction func get() {
		let isGet = getButton.currentTitle == "GET"
		getButton.setTitle(nil, for: .normal)
		getActivityIndicator.startAnimating()
		if isGet {
			firestore.document("users/\(id!)/decks/\(deckId!)").setData(["mastered": 0]) { error in
				if error == nil {
					self.getButtonWidthConstraint.constant = 90
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
						self.view.layoutIfNeeded()
						self.getActivityIndicator.stopAnimating()
						self.getButton.setTitle("DELETE", for: .normal)
						self.getButton.backgroundColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
					}, completion: nil)
				} else if let error = error {
					self.getActivityIndicator.stopAnimating()
					self.getButton.setTitle("GET", for: .normal)
					self.showAlert(error.localizedDescription)
				}
			}
		} else {
			firestore.document("users/\(id!)/decks/\(deckId!)").delete { error in
				if error == nil {
					self.getButtonWidthConstraint.constant = 70
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
						self.view.layoutIfNeeded()
						self.getActivityIndicator.stopAnimating()
						self.getButton.setTitle("GET", for: .normal)
						self.getButton.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
					}, completion: nil)
				} else if let error = error {
					self.getActivityIndicator.stopAnimating()
					self.getButton.setTitle("DELETE", for: .normal)
					self.showAlert(error.localizedDescription)
				}
			}
		}
	}
	
	@IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
		resizeCardsCollectionView()
		switch sender.selectedSegmentIndex {
		case 0:
			cardsCollectionView.isHidden = true
			descriptionWebView.isHidden = false
			creatorLabel.isHidden = false
		case 1:
			descriptionWebView.isHidden = true
			creatorLabel.isHidden = true
			cardsCollectionView.isHidden = false
		default:
			return
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cards.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BasicCardCollectionViewCell
		let element = cards[indexPath.item]
		cell.load(element.front)
		cell.action = {
			guard let cardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "card") as? CardViewController else { return }
			cardVC.card = element
			self.addChild(cardVC)
			cardVC.view.frame = self.view.frame
			self.view.addSubview(cardVC.view)
			cardVC.didMove(toParent: self)
		}
		return cell
	}
}

class BasicCardCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var label: UILabel!
	
	var action: (() -> Void)?
	
	@IBAction func click() {
		action?()
	}
	
	func load(_ text: String) {
		label.text = text.clean()
	}
}

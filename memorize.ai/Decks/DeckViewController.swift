import UIKit
import FirebaseFirestore

class DeckViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var getButton: UIButton!
	@IBOutlet weak var getButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var getActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var cardsTableView: UITableView!
	
	var deckId: String?
	var cards = [Card]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor.lightGray.cgColor
		firestore.collection("decks").document(deckId!).addSnapshotListener { snapshot, error in
			if error == nil, let snapshot = snapshot {
				self.nameLabel.text = snapshot.get("name") as? String ?? "Error"
				self.descriptionLabel.text = snapshot.get("description") as? String ?? "Error"
				self.activityIndicator.stopAnimating()
				self.loadingView.isHidden = true
			} else {
				self.activityIndicator.stopAnimating()
				let alertController = UIAlertController(title: "Error", message: "Unable to load deck", preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
					self.navigationController?.popViewController(animated: true)
				})
				self.present(alertController, animated: true, completion: nil)
			}
		}
		firestore.collection("decks").document(deckId!).collection("cards").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let card = $0.document
				let cardId = card.documentID
				switch $0.type {
				case .added:
					self.cards.append(Card(id: cardId, front: card.get("front") as? String ?? "Error", back: card.get("back") as? String ?? "Error", count: 0, correct: 0, streak: 0, mastered: false, last: "", history: [], deck: self.deckId!))
					self.cardsTableView.reloadData()
					callChangeHandler(.cardModified)
				case .modified:
					for i in 0..<self.cards.count {
						let oldCard = self.cards[i]
						if oldCard.id == cardId {
							self.cards[i].front = card.get("front") as? String ?? oldCard.front
							self.cards[i].back = card.get("back") as? String ?? oldCard.back
							self.cardsTableView.reloadData()
							callChangeHandler(.cardModified)
						}
					}
				case .removed:
					self.cards = self.cards.filter { return $0.id != cardId }
					self.cardsTableView.reloadData()
					callChangeHandler(.cardRemoved)
				}
			}
		}
		storage.child("decks/\(self.deckId!)").getData(maxSize: fileLimit) { data, error in
			if error == nil, let data = data {
				self.imageActivityIndicator.stopAnimating()
				self.imageView.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
			} else {
				self.showAlert("Unable to load image")
			}
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if Deck.id(deckId!) != nil {
			getButtonWidthConstraint.constant = 90
			getButton.setTitle("DELETE", for: .normal)
			getButton.backgroundColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		cardsTableView.isScrollEnabled = false
		cardsTableView.frame.size = cardsTableView.contentSize
	}
	
	@IBAction func get() {
		getButton.setTitle(nil, for: .normal)
		getActivityIndicator.startAnimating()
		if getButton.currentTitle == "GET" {
			firestore.collection("users").document(id!).collection("decks").document(deckId!).setData(["mastered": 0]) { error in
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
			firestore.collection("users").document(id!).collection("decks").document(deckId!).delete { error in
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
		switch sender.selectedSegmentIndex {
		case 0:
			cardsTableView.isHidden = true
			descriptionLabel.isHidden = false
		case 1:
			descriptionLabel.isHidden = true
			cardsTableView.isHidden = false
		default:
			return
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cards.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = cards[indexPath.row]
		cell.textLabel?.text = element.front
		cell.detailTextLabel?.text = element.back
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "card") as? CardViewController else { return }
		cardVC.card = cards[indexPath.row]
		addChild(cardVC)
		cardVC.view.frame = view.frame
		view.addSubview(cardVC.view)
		cardVC.didMove(toParent: self)
	}
}

import UIKit

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
		firestore.collection("decks").document(deckId!).getDocument { snapshot, error in
			if let snapshot = snapshot?.data(), error == nil {
				self.nameLabel.text = snapshot["name"] as? String ?? "Error"
				if Deck.id(self.deckId!) != nil {
					self.getButton.setTitle("DELETE", for: .normal)
					self.getButton.backgroundColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
				}
				self.descriptionLabel.text = snapshot["description"] as? String ?? "Error"
				self.activityIndicator.stopAnimating()
				self.loadingView.isHidden = true
			} else {
				self.activityIndicator.stopAnimating()
				let alertController = UIAlertController(title: "Error", message: "Unable to load deck", preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default) { action in
					self.navigationController?.popViewController(animated: true)
				}
				alertController.addAction(action)
				self.present(alertController, animated: true, completion: nil)
			}
		}
		firestore.collection("decks").document(deckId!).collection("cards").addSnapshotListener { snapshot, error in
			if let snapshot = snapshot?.documents, error == nil {
				self.cards = snapshot.map { Card(id: $0.documentID, front: $0.data()["front"] as? String ?? "Error", back: $0.data()["back"] as? String ?? "Error") }
				self.cardsTableView.reloadData()
			} else if let error = error {
				self.showAlert(error.localizedDescription)
			}
		}
		storage.child("decks/\(self.deckId!)").getData(maxSize: 50000000) { data, error in
			if let data = data, error == nil {
				self.imageActivityIndicator.stopAnimating()
				self.imageView.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
			} else {
				self.showAlert("Unable to load image")
			}
		}
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		cardsTableView.isScrollEnabled = false
		cardsTableView.frame.size = cardsTableView.contentSize
	}
	
	@IBAction func get() {
		let getDeck = getButton.currentTitle == "GET"
		getButton.setTitle(nil, for: .normal)
		getActivityIndicator.startAnimating()
		if getDeck {
			firestore.collection("users").document(id!).collection("decks").document(deckId!).setData(["name": nameLabel.text!, "count": cards.count, "mastered": 0]) { error in
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
		if let cardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "card") as? CardViewController {
			addChild(cardVC)
			cardVC.view.frame = view.frame
			view.addSubview(cardVC.view)
			cardVC.didMove(toParent: self)
		}
	}
}

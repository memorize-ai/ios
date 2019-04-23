import UIKit

class RecapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var cardsTableView: UITableView!
	
	var cards = [(id: String, deck: Deck, card: Card, correct: Bool, next: Date?)]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: true)
		let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(back))
		navigationItem.setRightBarButton(done, animated: true)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .cardModified {
				self.cardsTableView.reloadData()
			}
		}
	}
	
	@objc func back() {
		performSegue(withIdentifier: "done", sender: self)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cards.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = cards[indexPath.row]
		if let image = element.deck.image {
			cell.imageView?.image = image
		} else {
			storage.child("decks/\(element.deck.id)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data else { return }
				element.deck.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
				cell.imageView?.image = element.deck.image
				tableView.reloadData()
			}
		}
		cell.textLabel?.text = element.card.front
		if let next = element.next {
			cell.detailTextLabel?.text = next.format()
		} else {
			firestore.document("users/\(id!)/decks/\(element.deck.id)/cards/\(element.card.id)/history/\(element.id)").addSnapshotListener { snapshot, error in
				guard error == nil, let next = snapshot?.get("next") as? Date else { return }
				self.cards[indexPath.row] = (id: element.id, deck: element.deck, card: element.card, correct: element.correct, next: next)
				cell.detailTextLabel?.text = next.format()
				tableView.reloadData()
			}
		}
		return cell
	}
}

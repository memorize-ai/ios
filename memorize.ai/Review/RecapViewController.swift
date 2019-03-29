import UIKit

class RecapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var cardsTableView: UITableView!
	
	var deck: Deck?
	var cards = [(id: String, correct: Bool)]()
	
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
		let card = deck!.cards[deck!.card(id: element.id)!]
		if let image = deck?.image {
			cell.imageView?.image = image
		} else {
			storage.child("decks/\(deck!.id)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data else { return }
				self.deck?.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
				cell.imageView?.image = self.deck?.image
				tableView.reloadData()
			}
		}
		cell.textLabel?.text = card.front
		cell.detailTextLabel?.text = card.next.format()
		return cell
	}
}

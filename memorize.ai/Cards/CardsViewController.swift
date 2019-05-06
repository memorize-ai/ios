import UIKit

class CardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var cardsTableView: UITableView!
	
	var cards = [Card]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .deckModified || change == .deckRemoved || change == .cardModified || change == .cardRemoved {
				self.loadCards()
			}
		}
		loadCards()
	}
	
	func loadCards() {
		cards = Card.all().sorted { return $0.next.timeIntervalSinceNow < $1.next.timeIntervalSinceNow }
		cardsTableView.reloadData()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cards.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = cards[indexPath.row]
		guard let deckIndex = Deck.id(element.deck) else { return cell }
		let deck = decks[deckIndex]
		if let image = decks[deckIndex].image {
			cell.imageView?.image = image
		} else {
			storage.child("decks/\(element.deck)").getData(maxSize: fileLimit) { data, error in
				guard error == nil, let data = data else { return }
				deck.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
				cell.imageView?.image = deck.image
				tableView.reloadData()
			}
		}
		cell.textLabel?.text = element.front
		cell.detailTextLabel?.text = element.next.format()
		return cell
	}
}

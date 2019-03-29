import UIKit

class RecapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var cardsTableView: UITableView!
	
	var cards = [Card]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: true)
		let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(back))
		navigationItem.setRightBarButton(done, animated: true)
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
		cell.imageView?.image = decks[Deck.id(element.deck) ?? 0].image
		cell.textLabel?.text = element.front
		firestore.collection("users").document(
		cell.detailTextLabel?.text = element.next.format()
		return cell
	}
}

import UIKit

class CardAnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var analyticsTableView: UITableView!
	
	var deck: Deck?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .cardModified || change == .cardRemoved {
				self.analyticsTableView.reloadData()
			} else if change == .deckRemoved && !Deck.has(self.deck?.id) {
				self.navigationController?.popViewController(animated: true)
			}
		}
		updateCurrentViewController()
	}
	
	var cards: [Card] {
		return deck?.cards ?? []
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cards.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? CardAnalyticTableViewCell else { return _cell }
		let card = cards[indexPath.row]
		cell.cardLabel.text = card.front.clean()
		cell.likesLabel.text = String(card.likes)
		cell.dislikesLabel.text = String(card.dislikes)
		return cell
	}
}

class CardAnalyticTableViewCell: UITableViewCell {
	@IBOutlet weak var cardLabel: UILabel!
	@IBOutlet weak var likesLabel: UILabel!
	@IBOutlet weak var dislikesLabel: UILabel!
}

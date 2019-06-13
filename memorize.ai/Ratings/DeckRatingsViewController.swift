import UIKit

class DeckRatingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var ratingsTableView: UITableView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: self)
		if let rateDeckVC = segue.destination as? RateDeckViewController, let rating = sender as? DeckRating {
			rateDeckVC.rating = rating
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .deckRatingAdded || change == .deckRatingModified || change == .deckRatingRemoved {
				self.ratingsTableView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return deckRatings.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = deckRatings[indexPath.row]
		cell.textLabel?.text = element.deck?.name
		cell.detailTextLabel?.text = String(element.rating)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "editRating", sender: deckRatings[indexPath.row])
	}
}

import UIKit

class DeckAnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var analyticsTableView: UITableView!
	
	class AnalyticSection {
		let name: String
		let analytics: [Analytic]
		
		init(name: String, analytics: [Analytic]) {
			self.name = name
			self.analytics = analytics
		}
	}
	
	class Analytic {
		let key: String
		let value: String
		let color: UIColor
		
		init(key: String, value: String, color: UIColor = .black) {
			self.key = key
			self.value = value
			self.color = color
		}
		
		init(key: String, value: Int, color: UIColor = .black) {
			self.key = key
			self.value = String(value)
			self.color = color
		}
	}
	
	var deck: Deck?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .deckModified {
				self.analyticsTableView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	var analytics: [AnalyticSection] {
		guard let deck = deck else { return [] }
		let ratingsColor: UIColor = deck.ratings.average == 0 ? .lightGray : .black
		return [
			AnalyticSection(name: "ratings", analytics: [
				Analytic(key: "Average", value: String((deck.ratings.average * 10).rounded() / 10), color: ratingsColor),
				Analytic(key: "1 Star", value: deck.ratings.all1, color: ratingsColor),
				Analytic(key: "2 Star", value: deck.ratings.all2, color: ratingsColor),
				Analytic(key: "3 Star", value: deck.ratings.all3, color: ratingsColor),
				Analytic(key: "4 Star", value: deck.ratings.all4, color: ratingsColor),
				Analytic(key: "5 Star", value: deck.ratings.all5, color: ratingsColor)
			]),
			AnalyticSection(name: "views", analytics: [
				Analytic(key: "Total", value: deck.views.total),
				Analytic(key: "Unique", value: deck.views.unique)
			]),
			AnalyticSection(name: "downloads", analytics: [
				Analytic(key: "Total", value: deck.downloads.total),
				Analytic(key: "Current", value: deck.downloads.current)
			])
		]
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return analytics.count + 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return section == 0 ? nil : analytics[section - 1].name
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : analytics[section - 1].analytics.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "deckName", for: indexPath)
			cell.textLabel?.text = deck?.name
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			let element = analytics[indexPath.section - 1].analytics[indexPath.row]
			cell.textLabel?.text = element.key
			cell.detailTextLabel?.text = element.value
			cell.detailTextLabel?.textColor = element.color
			return cell
		}
	}
}

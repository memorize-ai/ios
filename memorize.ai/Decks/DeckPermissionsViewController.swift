import UIKit

class DeckPermissionsViewController: UIViewController {
	var deck: Deck?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCurrentViewController()
	}
}

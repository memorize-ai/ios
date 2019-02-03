import UIKit

class ChooseDeckTypeViewController: UIViewController {
	@IBOutlet weak var chooseDeckTypeView: UIView!
	@IBOutlet weak var titleBar: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		chooseDeckTypeView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.chooseDeckTypeView.transform = .identity
		}, completion: nil)
	}
	
	@IBAction func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.chooseDeckTypeView.transform = CGAffineTransform(scaleX: 0, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				self.view.removeFromSuperview()
			}
		}
	}
	
	@IBAction func createDeck() {
		clickedButton {
			guard let decksVC = self.parent as? DecksViewController else { return }
			decksVC.createDeck()
		}
	}
	
	@IBAction func searchDeck() {
		clickedButton {
			guard let decksVC = self.parent as? DecksViewController else { return }
			decksVC.searchDeck()
		}
	}
	
	func clickedButton(completion: @escaping () -> Void) {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.chooseDeckTypeView.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				self.view.removeFromSuperview()
				completion()
			}
		}
	}
}

import UIKit
import WebKit

class CardViewController: UIViewController {
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var frontWebView: WKWebView!
	@IBOutlet weak var backWebView: WKWebView!
	
	var card: Card?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners([.topLeft, .topRight], radius: 10)
		frontWebView.render(card!.front, fontSize: 60, textColor: "333333", backgroundColor: "ffffff", markdown: false)
		backWebView.render(card!.back, fontSize: 60, textColor: "333333", backgroundColor: "ffffff", markdown: false)
		cardView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.cardView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			self.frontWebView.render(self.card!.front, fontSize: 60, textColor: "333333", backgroundColor: "ffffff", markdown: false)
			self.backWebView.render(self.card!.back, fontSize: 60, textColor: "333333", backgroundColor: "ffffff", markdown: false)
		}
	}
	
	@IBAction func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.cardView.transform = CGAffineTransform(scaleX: 0, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				self.view.removeFromSuperview()
			}
		}
	}
}

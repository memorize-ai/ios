import UIKit
import WebKit

class CardViewController: UIViewController {
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var frontWebView: WKWebView!
	@IBOutlet weak var backWebView: WKWebView!
	@IBOutlet weak var leftButton: UIButton!
	@IBOutlet weak var rightButton: UIButton!
	
	var card: Card?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners([.topLeft, .topRight], radius: 10)
		frontWebView.render(card!.front, preview: false, fontSize: 55, textColor: "000000", backgroundColor: "ffffff")
		backWebView.render(card!.back, preview: false, fontSize: 55, textColor: "000000", backgroundColor: "ffffff")
		cardView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.cardView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update(nil)
		disable(leftButton)
	}
	
	@IBAction func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.cardView.transform = CGAffineTransform(scaleX: 0, y: 0)
			self.view.backgroundColor = .clear
		}) {
			guard $0 else { return }
			self.view.removeFromSuperview()
		}
	}
	
	@IBAction func back() {
		disable(rightButton)
		UIView.animate(withDuration: 0.125, animations: {
			self.frontWebView.transform = CGAffineTransform(translationX: -20, y: 0)
			self.frontWebView.alpha = 0
		}) {
			guard $0 else { return }
			self.frontWebView.isHidden = true
			self.backWebView.transform = CGAffineTransform(translationX: 20, y: 0)
			self.backWebView.alpha = 0
			self.backWebView.isHidden = false
			UIView.animate(withDuration: 0.125, animations: {
				self.backWebView.transform = .identity
				self.backWebView.alpha = 1
			}) {
				guard $0 else { return }
				self.enable(self.leftButton)
			}
		}
	}
	
	@IBAction func front() {
		disable(leftButton)
		UIView.animate(withDuration: 0.125, animations: {
			self.backWebView.transform = CGAffineTransform(translationX: 20, y: 0)
			self.backWebView.alpha = 0
		}) {
			guard $0 else { return }
			self.backWebView.isHidden = true
			self.frontWebView.transform = CGAffineTransform(translationX: -20, y: 0)
			self.frontWebView.alpha = 0
			self.frontWebView.isHidden = false
			UIView.animate(withDuration: 0.125, animations: {
				self.frontWebView.transform = .identity
				self.frontWebView.alpha = 1
			}) {
				guard $0 else { return }
				self.enable(self.rightButton)
			}
		}
	}
	
	func enable(_ button: UIButton) {
		button.isEnabled = true
		button.tintColor = .darkGray
	}
	
	func disable(_ button: UIButton) {
		button.isEnabled = false
		button.tintColor = .lightGray
	}
}

import UIKit
import WebKit

class CardPreviewViewController: UIViewController {
	@IBOutlet weak var frontWebView: WKWebView!
	@IBOutlet weak var frontWebViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var backWebView: WKWebView!
	@IBOutlet weak var backWebViewBottomConstraint: NSLayoutConstraint!
	
	func update(_ side: CardSide, text: String) {
		switch side {
		case .front:
			load(text, webView: frontWebView)
		case .back:
			load(text, webView: backWebView)
		}
	}
	
	private func load(_ text: String, webView: WKWebView) {
		webView.render(text, fontSize: 55)
	}
	
	func load(_ side: CardSide) {
		switch side {
		case .front:
			backWebView.isHidden = true
			frontWebView.isHidden = false
		case .back:
			frontWebView.isHidden = true
			backWebView.isHidden = false
		}
	}
	
	func swap(completion: ((CardSide) -> Void)?) {
		let halfWidth = view.bounds.width / 2
		if frontWebView.isHidden {
			UIView.animate(withDuration: 0.125, animations: {
				self.backWebView.transform = CGAffineTransform(translationX: halfWidth, y: 0)
				self.backWebView.alpha = 0
			}) {
				guard $0 else { return }
				self.backWebView.isHidden = true
				self.backWebView.transform = .identity
				self.backWebView.alpha = 1
				self.frontWebView.transform = CGAffineTransform(translationX: -halfWidth, y: 0)
				self.frontWebView.alpha = 0
				self.frontWebView.isHidden = false
				UIView.animate(withDuration: 0.125, animations: {
					self.frontWebView.transform = .identity
					self.frontWebView.alpha = 1
				}) {
					guard $0 else { return }
					completion?(.front)
				}
			}
		} else {
			UIView.animate(withDuration: 0.125, animations: {
				self.frontWebView.transform = CGAffineTransform(translationX: -halfWidth, y: 0)
				self.frontWebView.alpha = 0
			}) {
				guard $0 else { return }
				self.frontWebView.isHidden = true
				self.frontWebView.transform = .identity
				self.frontWebView.alpha = 1
				self.backWebView.transform = CGAffineTransform(translationX: halfWidth, y: 0)
				self.backWebView.alpha = 0
				self.backWebView.isHidden = false
				UIView.animate(withDuration: 0.125, animations: {
					self.backWebView.transform = .identity
					self.backWebView.alpha = 1
				}) {
					guard $0 else { return }
					completion?(.back)
				}
			}
		}
	}
}

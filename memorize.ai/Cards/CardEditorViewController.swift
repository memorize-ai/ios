import UIKit

class CardEditorViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var frontTextView: UITextView!
	@IBOutlet weak var backTextView: UITextView!
	
	private var listener: ((CardSide) -> Void)?
	
	func update(_ side: CardSide, text: String) {
		switch side {
		case .front:
			frontTextView.text = text
		case .back:
			backTextView.text = text
		}
	}
	
	func listen(handler: @escaping (CardSide) -> Void) {
		listener = handler
	}
	
	func textViewDidChange(_ textView: UITextView) {
		switch textView {
		case frontTextView:
			listener?(.front)
		case backTextView:
			listener?(.back)
		default:
			return
		}
	}
	
	func load(_ side: CardSide) {
		switch side {
		case .front:
			backTextView.isHidden = true
			frontTextView.isHidden = false
		case .back:
			frontTextView.isHidden = true
			backTextView.isHidden = false
		}
	}
	
	func swap(completion: @escaping (CardSide) -> Void) {
		let halfWidth = view.bounds.width / 2
		if frontTextView.isHidden {
			UIView.animate(withDuration: 0.25, animations: {
				self.backTextView.transform = CGAffineTransform(translationX: halfWidth, y: 0)
				self.backTextView.alpha = 0
			}) {
				guard $0 else { return }
				self.backTextView.isHidden = true
				self.backTextView.transform = .identity
				self.backTextView.alpha = 1
				self.frontTextView.transform = CGAffineTransform(translationX: -halfWidth, y: 0)
				self.frontTextView.alpha = 0
				self.frontTextView.isHidden = false
				UIView.animate(withDuration: 0.25, animations: {
					self.frontTextView.transform = .identity
					self.frontTextView.alpha = 1
				}) {
					guard $0 else { return }
					completion(.front)
				}
			}
		} else {
			UIView.animate(withDuration: 0.25, animations: {
				self.frontTextView.transform = CGAffineTransform(translationX: -halfWidth, y: 0)
				self.frontTextView.alpha = 0
			}) {
				guard $0 else { return }
				self.frontTextView.isHidden = true
				self.frontTextView.transform = .identity
				self.frontTextView.alpha = 1
				self.backTextView.transform = CGAffineTransform(translationX: halfWidth, y: 0)
				self.backTextView.alpha = 0
				self.backTextView.isHidden = false
				UIView.animate(withDuration: 0.25, animations: {
					self.backTextView.transform = .identity
					self.backTextView.alpha = 1
				}) {
					guard $0 else { return }
					completion(.back)
				}
			}
		}
	}
}

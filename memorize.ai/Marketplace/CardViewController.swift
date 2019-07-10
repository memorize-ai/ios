import UIKit
import WebKit

class CardViewController: UIViewController {
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var frontWebView: WKWebView!
	@IBOutlet weak var backWebView: WKWebView!
	@IBOutlet weak var leftButton: UIButton!
	@IBOutlet weak var rightButton: UIButton!
	
	var card: Card?
	var cell: CardPreviewCollectionViewCell?
	var playState = Audio.PlayState.ready
	var currentSide = CardSide.front
	
	override func viewDidLoad() {
		super.viewDidLoad()
		guard let card = card else { return }
		frontWebView.render(card.front, fontSize: 55)
		backWebView.render(card.back, fontSize: 55)
		cell?.completion = {
			self.setPlayState(.ready)
		}
		if Audio.isPlaying {
			setPlayState(.stop)
			playButton.isHidden = false
		} else {
			handleAudio()
		}
		cardView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.cardView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update(nil)
		disable(leftButton)
		updateCurrentViewController(stopAudio: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		cell?.completion = nil
		cell?.setPlayState(.ready)
		Audio.stop()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		titleBar.round(corners: [.topLeft, .topRight], radius: 10)
	}
	
	@IBAction
	func playButtonClicked() {
		switch playState {
		case .ready:
			playAudio()
		case .stop:
			Audio.stop()
			setPlayState(.ready)
		default:
			return
		}
	}
	
	@discardableResult
	func playAudio() -> Bool {
		guard let card = card, card.hasAudio(currentSide) else { return false }
		card.playAudio(currentSide) { success in
			self.playState = .ready
			if !success {
				self.showNotification("Unable to play audio. Please try again", type: .error)
			}
		}
		setPlayState(.stop)
		return true
	}
	
	func handleAudio() {
		if playAudio() {
			playButton.isHidden = false
		} else {
			playButton.isHidden = true
			Audio.stop()
		}
	}
	
	func setPlayButtonImage() {
		playButton.setImage(Audio.image(for: playState), for: .normal)
	}
	
	func setPlayState(_ playState: Audio.PlayState) {
		self.playState = playState
		setPlayButtonImage()
	}
	
	@IBAction
	func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.cardView.transform = CGAffineTransform(scaleX: 0, y: 0)
			self.view.backgroundColor = .clear
		}) {
			guard $0 else { return }
			self.view.removeFromSuperview()
		}
	}
	
	@IBAction
	func back() {
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
				self.currentSide = .back
				self.handleAudio()
			}
		}
	}
	
	@IBAction
	func front() {
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
				self.currentSide = .front
				self.handleAudio()
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

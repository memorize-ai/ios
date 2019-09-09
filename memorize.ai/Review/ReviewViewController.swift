import UIKit
import Firebase
import WebKit

class ReviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, FlowLayout {
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var frontWebView: WKWebView!
	@IBOutlet weak var backWebView: WKWebView!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var leftButton: UIButton!
	@IBOutlet weak var rightButton: UIButton!
	@IBOutlet weak var ratingView: UIView!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var dislikeButton: UIButton!
	@IBOutlet weak var ratingCollectionView: UICollectionView!
	@IBOutlet weak var ratingCollectionViewHeightConstraint: NSLayoutConstraint!
	
	typealias DueCard = (deck: Deck, card: Card)
	
	var current = 0
	var dueCards = [DueCard]()
	var reviewedCards = [(id: String, deck: Deck, card: Card, rating: PerformanceRating, next: Date?)]()
	var shouldSegue = false
	var previewDeck: String?
	var previewCards: [Card]?
	var isPushing = false
	var playState = Audio.PlayState.ready
	var currentSide = CardSide.front
	var didPause = false
	var currentCardRatingType = CardRatingType.none
	
	override func viewDidLoad() {
		super.viewDidLoad()
		backButton.layer.borderColor = UIColor.darkGray.cgColor
		setFlowLayouts()
		likeButton.adjustsImageWhenHighlighted = false
		dislikeButton.adjustsImageWhenHighlighted = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCurrentViewController()
		if let navigationController = navigationController, let semiBold = UIFont(name: "Nunito-SemiBold", size: 20) {
			navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: semiBold]
			navigationController.navigationBar.barTintColor = .white
			navigationController.navigationBar.tintColor = .darkGray
		}
		dueCards = getDueCards()
		currentCardRatingType = currentCard.ratingType
		handleAudio()
		ChangeHandler.updateAndCall(.cardModified) { change in
			if change == .cardModified || change == .deckModified {
				guard self.current < (self.previewCards?.count ?? self.dueCards.count) else { return }
				let card = self.currentCard
				self.load(card.front, webView: self.frontWebView)
				self.load(card.back, webView: self.backWebView)
				self.navigationItem.title = self.isReview ? self.dueCards[self.current].deck.name : self.previewDeck
			} else if change == .cardNextModified {
				self.reloadDueCards()
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		guard let navigationController = navigationController, let semiBold = UIFont(name: "Nunito-SemiBold", size: 20) else { return }
		navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: semiBold]
		navigationController.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
		navigationController.navigationBar.tintColor = .white
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		guard let recapVC = segue.destination as? RecapViewController else { return }
		recapVC.cards = reviewedCards
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: nil) { _ in
			self.setFlowLayouts()
			self.ratingCollectionView.reloadData()
		}
	}
	
	func setFlowLayouts() {
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: view.bounds.width - 40, height: 40)
		flowLayout.minimumLineSpacing = 8
		ratingCollectionView.collectionViewLayout = flowLayout
	}
	
	func getDueCards() -> [DueCard] {
		return decks.flatMap { deck in Card.sort(deck.cards.filter { $0.isDue() }, by: .due).map { (deck: deck, card: $0) } }
	}
	
	func reloadDueCards() {
		let onlyDueCards = dueCards[current..<dueCards.count]
		dueCards.append(contentsOf: getDueCards().filter { dueCard in
			!onlyDueCards.contains { $0.card.id == dueCard.card.id && $0.deck.id == dueCard.deck.id }
		})
		setProgress()
	}
	
	func setBarButtonItems(animated: Bool = true) {
		navigationItem.setRightBarButtonItems([
			getAudioBarButtonItem(image: Audio.image(for: playState)),
			UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadAudio))
			], animated: animated)
	}
	
	func getAudioBarButtonItem(image: UIImage) -> UIBarButtonItem {
		let button = UIButton(type: .custom)
		button.setImage(image, for: .normal)
		button.addTarget(self, action: #selector(audioControlsClicked), for: .touchUpInside)
		button.widthAnchor.constraint(equalToConstant: 32).isActive = true
		button.heightAnchor.constraint(equalToConstant: 32).isActive = true
		return UIBarButtonItem(customView: button)
	}
	
	@objc
	func reloadAudio() {
		Audio.stop()
		playAudio()
	}
	
	func playAudio(completion: @escaping (Bool) -> Void = { _ in }) {
		currentCard.playAudio(currentSide, completion: completion)
		setPlayState(.pause)
	}
	
	@objc
	func audioControlsClicked() {
		switch playState {
		case .ready:
			Audio.resume()
			setPlayState(.pause)
			didPause = false
		case .pause:
			Audio.pause()
			setPlayState(.ready)
			didPause = true
		default:
			break
		}
	}
	
	func setPlayState(_ playState: Audio.PlayState) {
		self.playState = playState
		setBarButtonItems(animated: false)
	}
	
	func handleAudio() {
		if currentCard.hasAudio(currentSide) {
			if !didPause {
				playAudio { _ in
					self.setPlayState(.ready)
				}
			}
			setBarButtonItems()
		} else {
			Audio.stop()
			removeBarButtonItems()
		}
	}
	
	func removeBarButtonItems(animated: Bool = true) {
		navigationItem.setRightBarButtonItems(nil, animated: animated)
	}
	
	@IBAction
	func back() {
		if backButton.isHidden {
			disable(rightButton)
		} else {
			loadRating(shouldShow: true)
			backButton.isEnabled = false
			leftButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			rightButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			leftButton.alpha = 0
			rightButton.alpha = 0
			leftButton.isHidden = false
			rightButton.isHidden = false
			disable(leftButton)
			disable(rightButton)
			UIView.animate(withDuration: 0.125, animations: {
				self.backButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
				self.backButton.alpha = 0
				self.leftButton.transform = .identity
				self.leftButton.alpha = 1
				self.rightButton.transform = .identity
				self.rightButton.alpha = 1
			}) {
				guard $0 else { return }
				self.backButton.isHidden = true
				self.backButton.isEnabled = true
			}
		}
		UIView.animate(withDuration: 0.125, animations: {
			self.frontWebView.transform = CGAffineTransform(translationX: -self.view.bounds.width / 2, y: 0)
			self.frontWebView.alpha = 0
		}) {
			guard $0 else { return }
			self.frontWebView.isHidden = true
			self.backWebView.transform = CGAffineTransform(translationX: self.view.bounds.width / 2, y: 0)
			self.backWebView.alpha = 0
			self.backWebView.isHidden = false
			UIView.animate(withDuration: 0.125, animations: {
				self.backWebView.transform = .identity
				self.backWebView.alpha = 1
			}) {
				guard $0 else { return }
				self.enable(self.leftButton)
				self.currentSide = .back
				Audio.pause()
				self.handleAudio()
				if self.backButton.isHidden {
					self.ratingCollectionViewHeightConstraint.constant = self.ratingCollectionView.contentSize.height
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: self.view.layoutIfNeeded, completion: nil)
				}
			}
		}
	}
	
	@IBAction
	func front() {
		disable(leftButton)
		UIView.animate(withDuration: 0.125, animations: {
			self.backWebView.transform = CGAffineTransform(translationX: self.view.bounds.width / 2, y: 0)
			self.backWebView.alpha = 0
		}) {
			guard $0 else { return }
			self.backWebView.isHidden = true
			self.frontWebView.transform = CGAffineTransform(translationX: -self.view.bounds.width / 2, y: 0)
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
	
	@IBAction
	func like() {
		switch currentCardRatingType {
		case .like:
			likeButton.setImage(#imageLiteral(resourceName: "Unselected Like"), for: .normal)
			dislikeButton.setImage(#imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
			rateCurrentCard(.none)
		case .dislike, .none:
			likeButton.setImage(#imageLiteral(resourceName: "Selected Like"), for: .normal)
			dislikeButton.setImage(#imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
			rateCurrentCard(.like)
		}
	}
	
	@IBAction
	func dislike() {
		switch currentCardRatingType {
		case .dislike:
			likeButton.setImage(#imageLiteral(resourceName: "Unselected Like"), for: .normal)
			dislikeButton.setImage(#imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
			rateCurrentCard(.none)
		case .like, .none:
			likeButton.setImage(#imageLiteral(resourceName: "Unselected Like"), for: .normal)
			dislikeButton.setImage(#imageLiteral(resourceName: "Selected Dislike"), for: .normal)
			rateCurrentCard(.dislike)
		}
	}
	
	func rateCurrentCard(_ rating: CardRatingType) {
		currentCardRatingType = rating
		currentCard.rate(rating) { error in
			if error != nil {
				self.showNotification("Unable to rate card. Please try again", type: .error)
			}
		}
	}
	
	func loadRating(shouldShow: Bool = false) {
		guard isReview else {
			ratingView.isHidden = true
			return
		}
		switch currentCardRatingType {
		case .like:
			likeButton.setImage(#imageLiteral(resourceName: "Selected Like"), for: .normal)
			dislikeButton.setImage(#imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
		case .dislike:
			likeButton.setImage(#imageLiteral(resourceName: "Unselected Like"), for: .normal)
			dislikeButton.setImage(#imageLiteral(resourceName: "Selected Dislike"), for: .normal)
		case .none:
			likeButton.setImage(#imageLiteral(resourceName: "Unselected Like"), for: .normal)
			dislikeButton.setImage(#imageLiteral(resourceName: "Unselected Dislike"), for: .normal)
		}
		if shouldShow {
			ratingView.alpha = 0
			ratingView.isHidden = false
			UIView.animate(withDuration: 0.5) {
				self.ratingView.alpha = 1
			}
		}
	}
	
	var isReview: Bool {
		return previewDeck == nil
	}
	
	var currentCard: Card {
		return previewCards?[current] ?? dueCards[current].card
	}
	
	func enable(_ button: UIButton) {
		button.isEnabled = true
		button.tintColor = .darkGray
	}
	
	func disable(_ button: UIButton) {
		button.isEnabled = false
		button.tintColor = .lightGray
	}
	
	func normalize(rating: Int) -> Int {
		return PerformanceRating.ratings.count - rating - 1
	}
	
	func load(_ text: String, webView: WKWebView) {
		webView.render(text, fontSize: 55)
	}
	
	func goToRecap() {
		performSegue(withIdentifier: "recap", sender: self)
	}
	
	func push(rating: Int) {
		isPushing = true
		guard let id = id else { return isPushing = false }
		func handlePushing() {
			if shouldSegue {
				goToRecap()
			}
			isPushing = false
		}
		let element = dueCards[current]
		var documentReference: DocumentReference?
		documentReference = firestore.collection("users/\(id)/decks/\(element.deck.id)/cards/\(element.card.id)/history").addDocument(data: ["rating": rating]) { error in
			guard error == nil, let documentReference = documentReference else { return self.isPushing = false }
			let historyId = documentReference.documentID
			for i in 0..<self.reviewedCards.count {
				let reviewedCard = self.reviewedCards[i]
				guard reviewedCard.card.id == element.card.id && reviewedCard.deck.id == element.deck.id else { continue }
				self.reviewedCards[i] = (
					id: historyId,
					deck: element.deck,
					card: element.card,
					rating: PerformanceRating.get(rating),
					next: nil
				)
				handlePushing()
				return
			}
			self.reviewedCards.append((
				id: historyId,
				deck: element.deck,
				card: element.card,
				rating: PerformanceRating.get(rating),
				next: nil
			))
			handlePushing()
		}
	}
	
	func setProgress() {
		progressView.setProgress(Float(current) / Float(isReview ? dueCards.count : previewCards?.count ?? 0), animated: true)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return PerformanceRating.ratings.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? RatingCollectionViewCell else { return _cell }
		let element = PerformanceRating.get(normalize(rating: indexPath.item))
		cell.imageView.image = element.image
		cell.label.text = element.description
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if isReview {
			push(rating: normalize(rating: indexPath.item))
		}
		current += 1
		setProgress()
		let count = isReview ? dueCards.count : previewCards?.count ?? 0
		UIView.animate(withDuration: 0.125, animations: {
			self.leftButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			self.leftButton.alpha = 0
			self.rightButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			self.rightButton.alpha = 0
		}) {
			guard $0 else { return }
			if self.current < count {
				self.navigationItem.title = self.isReview ? self.dueCards[self.current].deck.name : self.previewDeck
				let card = self.currentCard
				self.currentCardRatingType = card.ratingType
				if self.frontWebView.isHidden {
					self.load(card.front, webView: self.frontWebView)
					UIView.animate(withDuration: 0.125, animations: {
						self.backWebView.transform = CGAffineTransform(translationX: -self.view.bounds.width / 2, y: 0)
						self.backWebView.alpha = 0
					}) {
						guard $0 else { return }
						self.backWebView.isHidden = true
						self.load(card.back, webView: self.backWebView)
						self.frontWebView.transform = CGAffineTransform(translationX: self.view.bounds.width / 2, y: 0)
						self.frontWebView.alpha = 0
						self.frontWebView.isHidden = false
						UIView.animate(withDuration: 0.125, animations: {
							self.frontWebView.transform = .identity
							self.frontWebView.alpha = 1
						}) {
							guard $0 else { return }
							self.backButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
							self.backButton.alpha = 0
							self.backButton.isHidden = false
							UIView.animate(withDuration: 0.125, animations: {
								self.backButton.transform = .identity
								self.backButton.alpha = 1
							}) {
								guard $0 else { return }
								self.currentSide = .front
								self.handleAudio()
							}
						}
					}
				} else {
					self.load(card.back, webView: self.backWebView)
					UIView.animate(withDuration: 0.125, animations: {
						self.frontWebView.transform = CGAffineTransform(translationX: -self.view.bounds.width / 2, y: 0)
						self.frontWebView.alpha = 0
					}) {
						guard $0 else { return }
						self.load(card.front, webView: self.frontWebView)
						self.frontWebView.transform = CGAffineTransform(translationX: self.view.bounds.width / 2, y: 0)
						UIView.animate(withDuration: 0.125, animations: {
							self.frontWebView.transform = .identity
							self.frontWebView.alpha = 1
						}) {
							guard $0 else { return }
							self.backButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
							self.backButton.alpha = 0
							self.backButton.isHidden = false
							UIView.animate(withDuration: 0.125, animations: {
								self.backButton.transform = .identity
								self.backButton.alpha = 1
							}) {
								guard $0 else { return }
								self.currentSide = .back
								self.handleAudio()
							}
						}
					}
				}
			} else if self.isReview {
				if self.isPushing {
					self.shouldSegue = true
				} else {
					self.goToRecap()
				}
			} else {
				self.navigationController?.popViewController(animated: true)
			}
		}
		ratingCollectionViewHeightConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.view.layoutIfNeeded()
			self.ratingView.alpha = 0
		}) {
			guard $0 else { return }
			self.ratingView.isHidden = true
			self.ratingView.alpha = 1
			self.loadRating()
		}
	}
}

class RatingCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
}

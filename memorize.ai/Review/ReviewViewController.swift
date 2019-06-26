import UIKit
import Firebase
import WebKit

class ReviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var frontWebView: WKWebView!
	@IBOutlet weak var backWebView: WKWebView!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var leftButton: UIButton!
	@IBOutlet weak var rightButton: UIButton!
	@IBOutlet weak var ratingCollectionView: UICollectionView!
	@IBOutlet weak var ratingCollectionViewHeightConstraint: NSLayoutConstraint!
	
	var current = 0
	var dueCards = [(deck: Deck, card: Card)]()
	var reviewedCards = [(id: String, deck: Deck, card: Card, rating: PerformanceRating, next: Date?)]()
	var shouldSegue = false
	var previewDeck: String?
	var previewCards: [Card]?
	var isPushing = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		backButton.layer.borderColor = UIColor.darkGray.cgColor
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: view.bounds.width - 40, height: 40)
		flowLayout.minimumLineSpacing = 8
		ratingCollectionView.collectionViewLayout = flowLayout
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let navigationController = navigationController, let semiBold = UIFont(name: "Nunito-SemiBold", size: 20) {
			navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: semiBold]
			navigationController.navigationBar.barTintColor = .white
			navigationController.navigationBar.tintColor = .darkGray
		}
		dueCards = decks.flatMap { deck in return Card.sort(deck.cards.filter { $0.isDue() }, by: .due).map { (deck: deck, card: $0) } }
		ChangeHandler.updateAndCall(.cardModified) { change in
			if change == .cardModified || change == .deckModified {
				guard self.current < self.dueCards.count else { return }
				if self.isReview {
					let element = self.dueCards[self.current]
					self.load(element.card.front, webView: self.frontWebView)
					self.load(element.card.back, webView: self.backWebView)
					self.navigationItem.title = element.deck.name
				} else if let previewCards = self.previewCards {
					let element = previewCards[self.current]
					self.load(element.front, webView: self.frontWebView)
					self.load(element.back, webView: self.backWebView)
					self.navigationItem.title = self.previewDeck
				}
			}
		}
		updateCurrentViewController()
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
	
	@IBAction
	func back() {
		if backButton.isHidden {
			disable(rightButton)
		} else {
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
			}
		}
	}
	
	var isReview: Bool {
		return previewDeck == nil
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
		webView.render(text, fontSize: 55, textColor: "000000", backgroundColor: "ffffff")
	}
	
	func goToRecap() {
		performSegue(withIdentifier: "recap", sender: self)
	}
	
	func push(rating: Int) {
		isPushing = true
		guard let id = id else { return isPushing = false }
		let element = dueCards[current]
		var documentReference: DocumentReference?
		documentReference = firestore.collection("users/\(id)/decks/\(element.deck.id)/cards/\(element.card.id)/history").addDocument(data: ["rating": rating]) { error in
			guard error == nil, let documentReference = documentReference else { return self.isPushing = false }
			self.reviewedCards.append((id: documentReference.documentID, deck: element.deck, card: element.card, rating: PerformanceRating.get(rating), next: nil))
			if self.shouldSegue {
				self.goToRecap()
			}
			self.isPushing = false
		}
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
		let count = isReview ? dueCards.count : previewCards?.count ?? 0
		progressView.setProgress(Float(current) / Float(count), animated: true)
		UIView.animate(withDuration: 0.125, animations: {
			self.leftButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			self.leftButton.alpha = 0
			self.rightButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			self.rightButton.alpha = 0
		}) {
			guard $0 else { return }
			if self.current < count {
				self.navigationItem.title = self.isReview ? self.dueCards[self.current].deck.name : self.previewDeck
				guard let card = self.isReview ? self.dueCards[self.current].card : self.previewCards?[self.current] else { return }
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
							UIView.animate(withDuration: 0.125) {
								self.backButton.transform = .identity
								self.backButton.alpha = 1
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
							UIView.animate(withDuration: 0.125) {
								self.backButton.transform = .identity
								self.backButton.alpha = 1
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
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: view.layoutIfNeeded, completion: nil)
	}
}

class RatingCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
}

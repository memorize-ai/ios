import UIKit
import FirebaseFirestore
import WebKit

class ReviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var frontWebView: WKWebView!
	@IBOutlet weak var frontWebViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var backWebView: WKWebView!
	@IBOutlet weak var backWebViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingCollectionView: UICollectionView!
	@IBOutlet weak var ratingCollectionViewHeightConstraint: NSLayoutConstraint!
	
	var current = 0
	var dueCards = [(deck: Deck, card: Card)]()
	var reviewedCards = [(id: String, deck: Deck, card: Card, rating: Rating, next: Date?)]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: UIFont(name: "Nunito-SemiBold", size: 20)!]
		navigationController?.navigationBar.barTintColor = .white
		navigationController?.navigationBar.tintColor = .darkGray
		dueCards = decks.flatMap { deck in return deck.cards.filter { return $0.isDue() }.map { return (deck: deck, card: $0) } }
		ChangeHandler.updateAndCall(.cardModified) { change in
			if change == .cardModified || change == .deckModified {
				let element = self.dueCards[self.current]
				self.load(element.card.front, webView: self.frontWebView)
				self.load(element.card.back, webView: self.backWebView)
				self.navigationItem.title = element.deck.name
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "Nunito-SemiBold", size: 20)!]
		navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
		navigationController?.navigationBar.tintColor = .white
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let recapVC = segue.destination as? RecapViewController else { return }
		recapVC.cards = reviewedCards
	}
	
	@objc func tappedScreen() {
		if backWebView.isHidden {
			barView.alpha = 0
			backWebView.alpha = 0
			barView.isHidden = false
			backWebView.isHidden = false
			UIView.animate(withDuration: 0.5) {
				self.barView.alpha = 1
				self.backWebView.alpha = 1
			}
			ratingCollectionViewHeightConstraint.constant = ratingCollectionView.contentSize.height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
		}
	}
	
	func normalize(rating: Int) -> Int {
		return Rating.ratings.count - rating - 1
	}
	
	func load(_ text: String, webView: WKWebView) {
		webView.render(text, fontSize: 90, textColor: "000000", backgroundColor: "ffffff")
	}
	
	func push(rating: Int) {
		let element = dueCards[current]
		var documentReference: DocumentReference?
		documentReference = firestore.collection("users/\(id!)/decks/\(element.deck.id)/cards/\(element.card.id)/history").addDocument(data: ["rating": rating]) { error in
			guard error == nil, let documentReference = documentReference else { return }
			self.reviewedCards.append((id: documentReference.documentID, deck: element.deck, card: element.card, rating: Rating.get(rating), next: nil))
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Rating.ratings.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RatingCollectionViewCell
		let element = Rating.get(normalize(rating: indexPath.item))
		cell.imageView.image = element.image
		cell.label.text = element.description
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		push(rating: normalize(rating: indexPath.item))
		current += 1
		progressView.setProgress(Float(current) / Float(dueCards.count), animated: true)
		let shouldContinue = current < dueCards.count
		if shouldContinue {
			UIView.animate(withDuration: 0.25, animations: {
				self.frontWebView.alpha = 0
				self.navigationItem.title = self.dueCards[self.current].deck.name
			}) { finished in
				if finished {
					self.load(self.dueCards[self.current].card.front, webView: self.frontWebView)
					UIView.animate(withDuration: 0.25) {
						self.frontWebView.alpha = 1
					}
				}
			}
		}
		UIView.animate(withDuration: 0.5, animations: {
			self.barView.alpha = 0
			self.backWebView.alpha = 0
		}) { finished in
			if finished {
				self.barView.isHidden = true
				self.backWebView.isHidden = true
				if shouldContinue {
					let element = self.dueCards[self.current].card
					self.load(element.back, webView: self.backWebView)
				} else {
					self.performSegue(withIdentifier: "recap", sender: self)
				}
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

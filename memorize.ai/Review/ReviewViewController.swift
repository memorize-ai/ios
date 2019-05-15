import UIKit
import FirebaseFirestore
import WebKit

class ReviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var frontWebView: WKWebView!
	@IBOutlet weak var frontWebViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var backWebView: WKWebView!
	@IBOutlet weak var backWebViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingCollectionView: UICollectionView!
	
	var dueCards = [(deck: Deck, card: Card)]()
	var reviewedCards = [(id: String, deck: Deck, card: Card, quality: Int, next: Date?)]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.cardDue) { change in
			if change == .cardModified || change == .cardRemoved {
				let _dueCards = self.loadDueCards()
				if self.dueCards.count != _dueCards.count {
					self.dueCards = _dueCards
				}
				let currentCard = self.current().card
				self.load(currentCard.front, webView: self.frontWebView)
				self.load(currentCard.back, webView: self.backWebView)
			}
		}
	}
	
	func loadDueCards() -> [(deck: Deck, card: Card)] {
		return decks.flatMap { deck in return deck.cards.filter { return $0.isDue() }.map { return (deck: deck, card: $0) } }
	}
	
	func current() -> (deck: Deck, card: Card) {
		return dueCards.first!
	}
	
	func qualityButtons() -> [UIButton] {
		return [quality0Button, quality1Button, quality2Button, quality3Button, quality4Button, quality5Button]
	}
	
	func qualityButton(_ index: Int) -> UIButton {
		return qualityButtons()[index]
	}
	
	func deselectQualityButtons() {
		qualityButtons().forEach { $0.layer.borderColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1) }
		load
	}
	
	func load(_ text: String, webView: WKWebView) {
		webView.render(text, fontSize: 90, textColor: "333333", backgroundColor: "e7e7e7", markdown: false/*true*/)
	}
	
	@IBAction func next(_ sender: UIButton) {
		guard let index = qualityButtons().firstIndex(of: sender) else { return }
		createHistory(index)
		slideAnimation()
	}
	
	@objc func tappedScreen() {
		if qualityImageView.isHidden {
			flipAnimation()
		}
	}
	
	func createHistory(_ quality: Int) {
		var documentReference: DocumentReference?
		documentReference = firestore.collection("users/\(id!)/decks/\(current().deck.id)/cards/\(current().card.id)/history").addDocument(data: ["rating": quality]) { error in
			guard error == nil, let documentReference = documentReference else { return }
			self.reviewedCards.append((id: documentReference.documentID, deck: self.current().deck, card: self.current().card, quality: quality, next: nil))
		}
	}
	
	func hideQualityView(_ hidden: Bool) {
		([qualityImageView] + qualityButtons()).forEach { $0?.isHidden = hidden }
	}
	
	func flipAnimation() {
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.cardView.transform = CGAffineTransform(scaleX: CGFloat.ulpOfOne, y: 1)
		}) { finished in
			if finished {
				self.hideQualityView(false)
				self.cardBarView.isHidden = false
				self.backLabel.isHidden = false
				self.backLabel.text = self.current().card.back
				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
					self.cardView.transform = .identity
				}, completion: nil)
			}
		}
	}
	
	func slideAnimation() {
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.cardView.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
		}) { finished in
			if finished {
				self.newCard()
				self.hideQualityView(true)
				self.frontLabel.text = self.current().card.front
				self.cardBarView.isHidden = true
				self.backLabel.isHidden = true
				self.cardView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
					self.cardView.transform = .identity
				}, completion: nil)
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let recapVC = segue.destination as? RecapViewController else { return }
		recapVC.cards = reviewedCards
	}
	
	func newCard() {
		if dueCards.count == 1 {
			performSegue(withIdentifier: "recap", sender: self)
		} else {
			dueCards.removeFirst()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Rating.ratings.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RatingCollectionViewCell
		let element = Rating.get(indexPath.item)
		cell.imageView.image = element.image
		cell.label.text = element.description
		return cell
	}
}

class RatingCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
}

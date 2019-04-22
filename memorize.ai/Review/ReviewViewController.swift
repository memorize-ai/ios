import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController {
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var frontLabel: UILabel!
	@IBOutlet weak var cardBarView: UIView!
	@IBOutlet weak var backLabel: UILabel!
	@IBOutlet weak var dontKnowButton: UIButton!
	
	var dueCards = [(deck: Deck, card: Card)]()
	var correct = false
	var reviewedCards = [(deck: Deck, card: Card, correct: Bool, next: Date)]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
		cardView.layer.borderWidth = 1
		cardView.layer.borderColor = UIColor.lightGray.cgColor
		dontKnowButton.layer.borderWidth = 1
		dontKnowButton.layer.borderColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		dueCards = decks.flatMap { deck in return deck.cards.filter { return $0.isDue() }.map { return (deck: deck, card: $0) } }
		frontLabel.text = current().card.front
	}
	
	func current() -> (deck: Deck, card: Card) {
		return dueCards.first!
	}
	
	@IBAction func dontKnow() {
		createHistory(false)
		flipAnimation()
	}
	
	@objc func tappedScreen() {
		if dontKnowButton.isHidden {
			slideAnimation()
		} else {
			createHistory(true)
			flipAnimation()
		}
	}
	
	func createHistory(_ correct: Bool) {
		let deckId = current().deck.id
		let cardId = current().card.id
		var documentReference: DocumentReference?
		documentReference = firestore.collection("users/\(id!)/decks/\(deckId)/cards/\(cardId)/history").addDocument(data: ["correct": correct]) { error in
			guard error == nil, let documentReference = documentReference else { return }
			firestore.document("users/\(id!)/decks/\(deckId)/cards/\(cardId)/history/\(documentReference.documentID)").addSnapshotListener { snapshot, historyError in
				guard historyError == nil, let next = snapshot?.get("next") as? Date else { return }
				self.reviewedCards.append((deck: self.current().deck, card: self.current().card, correct: self.correct, next: next))
			}
		}
	}
	
	func flipAnimation() {
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.cardView.transform = CGAffineTransform(scaleX: CGFloat.ulpOfOne, y: 1)
		}) { finished in
			if finished {
				self.cardBarView.isHidden = false
				self.backLabel.isHidden = false
				self.backLabel.text = self.current().card.back
				self.dontKnowButton.isHidden = true
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
				self.frontLabel.text = self.current().card.front
				self.cardBarView.isHidden = true
				self.backLabel.isHidden = true
				self.dontKnowButton.isHidden = false
				self.cardView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
					self.cardBarView.transform = .identity
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
			dueCards = Array(dueCards.dropFirst())
		}
	}
}

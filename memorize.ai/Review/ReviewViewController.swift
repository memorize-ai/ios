import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController {
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var frontLabel: UILabel!
	@IBOutlet weak var cardBarView: UIView!
	@IBOutlet weak var backLabel: UILabel!
	@IBOutlet weak var dontKnowButton: UIButton!
	
	var deck: Deck?
	var card = 0
	var correct = false
	var reviewedCards = [(id: String, correct: Bool)]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
		frontLabel.text = deck?.cards[card].front ?? "Error"
		cardView.layer.borderWidth = 1
		cardView.layer.borderColor = UIColor.lightGray.cgColor
		dontKnowButton.layer.borderWidth = 1
		dontKnowButton.layer.borderColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .cardModified {
				let card = self.deck?.cards[self.card]
				self.frontLabel.text = card?.front ?? "Error"
				self.backLabel.text = card?.back ?? "Error"
			}
		}
	}
	
	@IBAction func dontKnow() {
		correct = false
		createHistory()
		flipAnimation()
	}
	
	@objc func tappedScreen() {
		if dontKnowButton.isHidden {
			slideAnimation()
		} else {
			correct = true
			createHistory()
			flipAnimation()
		}
	}
	
	func createHistory() {
		firestore.collection("users").document(id!).collection("decks").document(deck!.id).collection("cards").document(deck!.cards[card].id).collection("history").addDocument(data: ["correct": correct])
	}
	
	func flipAnimation() {
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.cardView.transform = CGAffineTransform(scaleX: 0.01, y: 1)
		}) { finished in
			if finished {
				let card = self.deck!.cards[self.card]
				self.reviewedCards.append((id: card.id, correct: self.correct))
				self.cardBarView.isHidden = false
				self.backLabel.isHidden = false
				self.backLabel.text = card.back
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
				self.frontLabel.text = self.deck?.cards[self.card].front
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
		recapVC.deck = deck
		recapVC.cards = reviewedCards
	}
	
	func newCard() {
		if card == deck!.cards.count - 1 {
			performSegue(withIdentifier: "recap", sender: self)
		} else {
			card += 1
		}
	}
}

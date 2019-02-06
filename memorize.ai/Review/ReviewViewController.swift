import UIKit
import Firebase

class ReviewViewController: UIViewController {
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var frontLabel: UILabel!
	@IBOutlet weak var cardBarView: UIView!
	@IBOutlet weak var backLabel: UILabel!
	@IBOutlet weak var dontKnowButton: UIButton!
	
	var deck: Deck?
	var card = 0
	var reviewedCards = [Card]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedScreen))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
		frontLabel.text = deck?.cards[card].front
		cardView.layer.borderWidth = 1
		cardView.layer.borderColor = UIColor.lightGray.cgColor
		dontKnowButton.layer.borderWidth = 1
		dontKnowButton.layer.borderColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
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
		firestore.collection("users").document(id!).collection("cards").document(deck!.cards[card].id).collection("history").addDocument(data: ["date": Timestamp(), "correct": correct])
	}
	
	func flipAnimation() {
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.cardView.transform = CGAffineTransform(scaleX: 0.01, y: 1)
		}) { finished in
			if finished {
				let card = self.deck!.cards[self.card]
				self.reviewedCards.append(card)
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

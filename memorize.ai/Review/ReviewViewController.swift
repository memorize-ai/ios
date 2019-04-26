import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController {
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var frontLabel: UILabel!
	@IBOutlet weak var cardBarView: UIView!
	@IBOutlet weak var backLabel: UILabel!
	@IBOutlet weak var hardestLabel: UILabel!
	@IBOutlet weak var qualityImageView: UIImageView!
	@IBOutlet weak var quality0Button: UIButton!
	@IBOutlet weak var quality1Button: UIButton!
	@IBOutlet weak var quality2Button: UIButton!
	@IBOutlet weak var quality3Button: UIButton!
	@IBOutlet weak var quality4Button: UIButton!
	@IBOutlet weak var quality5Button: UIButton!
	@IBOutlet weak var easiestLabel: UILabel!
	
	var dueCards = [(deck: Deck, card: Card)]()
	var reviewedCards = [(id: String, deck: Deck, card: Card, quality: Int, next: Date?)]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
		cardView.layer.borderWidth = 1
		cardView.layer.borderColor = UIColor.lightGray.cgColor
		deselectQualityButtons()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		dueCards = decks.flatMap { deck in return deck.cards.filter { return $0.isDue() }.map { return (deck: deck, card: $0) } }
		frontLabel.text = current().card.front
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
	}
	
	@IBAction func next(_ sender: UIButton) {
		guard let index = qualityButtons().firstIndex(of: sender) else { return }
		createHistory(index)
		flipAnimation()
	}
	
	@objc func tappedScreen() {
		if qualityImageView.isHidden {
			slideAnimation()
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
		([hardestLabel, qualityImageView, easiestLabel] + qualityButtons()).forEach { $0?.isHidden = hidden }
	}
	
	func flipAnimation() {
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.cardView.transform = CGAffineTransform(scaleX: CGFloat.ulpOfOne, y: 1)
		}) { finished in
			if finished {
				self.hideQualityView(true)
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
				self.hideQualityView(false)
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
}

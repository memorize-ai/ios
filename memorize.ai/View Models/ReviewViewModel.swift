import Combine

final class ReviewViewModel: ViewModel {
	let user: User
	let deck: Deck?
	let section: Deck.Section?
	
	let numberOfCards: Int
	
	@Published var currentCard: Card?
	@Published var currentCardIndex = -1
	
	@Published var isWaitingForPerformanceRating = false
	
	init(user: User, deck: Deck?, section: Deck.Section?) {
		self.user = user
		self.deck = deck
		self.section = section
		
		if let section = section {
			numberOfCards = section.numberOfDueCards
		} else if let deck = deck {
			numberOfCards = deck.userData?.numberOfDueCards ?? 0
		} else {
			numberOfCards = user.numberOfDueCards
		}
		
		loadNextCard()
	}
	
	func loadNextCard() {
//		currentCardIndex++
//
//		if currentCardIndex ==
//
//		if let deck = deck {
//			if let section = section {
//				firestore
//					.collection("decks/\(deck.id)/cards")
//					.whereField("section", isEqualTo: section.id)
//					.start(afterDocument: )
//			} else {
//
//			}
//		} else {
//
//		}
	}
}

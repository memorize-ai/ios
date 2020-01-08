import Foundation
import Combine
import FirebaseFirestore

final class ReviewViewModel: ViewModel {
	let user: User
	let deck: Deck?
	let section: Deck.Section?
	
	let numberOfCards: Int
	
	@Published var currentCard: Card?
	@Published var currentCardSnapshot: DocumentSnapshot?
	@Published var currentCardIndex = -1
	
	@Published var isWaitingForPerformanceRating = false
	
	var isDoneWithSeenCards = false
	
	init(user: User, deck: Deck?, section: Deck.Section?) {
		self.user = user
		self.deck = deck
		self.section = section
		
		if let section = section {
			numberOfCards = section.numberOfDueCards ?? 0
		} else if let deck = deck {
			numberOfCards = deck.userData?.numberOfDueCards ?? 0
		} else {
			numberOfCards = user.numberOfDueCards
		}
		
		loadNextCard()
	}
	
	func loadNextCard() {
		currentCardIndex++
		
		// TODO: Load next card
	}
}

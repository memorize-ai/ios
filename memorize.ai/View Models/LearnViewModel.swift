final class LearnViewModel: ViewModel {
	let deck: Deck
	let section: Deck.Section?
	
	let numberOfTotalCards: Int
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
		
		numberOfTotalCards = section?.numberOfCards ?? deck.numberOfCards
	}
	
	var numberOfMasteredCards: Int {
		0 // TODO: Change this
	}
	
	var numberOfSeenCards: Int {
		0 // TODO: Change this
	}
	
	var numberOfUnseenCards: Int {
		0 // TODO: Change this
	}
}

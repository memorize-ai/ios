final class LearnViewModel: ViewModel {
	let deck: Deck
	let section: Deck.Section?
	
	let numberOfCards: Int
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
		
		numberOfCards = section?.numberOfCards ?? deck.numberOfCards
	}
}

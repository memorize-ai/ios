final class LearnViewModel: ViewModel {
	let deck: Deck
	let section: Deck.Section?
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
	}
}

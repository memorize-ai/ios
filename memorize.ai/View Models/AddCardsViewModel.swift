import Combine

final class AddCardsViewModel: ViewModel {
	let deck: Deck
	
	init(deck: Deck) {
		self.deck = deck
	}
}

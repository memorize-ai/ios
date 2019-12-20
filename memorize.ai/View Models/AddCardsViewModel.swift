import Combine

final class AddCardsViewModel: ViewModel {
	let deck: Deck
	
	@Published var cards = [Card]()
	
	init(deck: Deck) {
		self.deck = deck
	}
}

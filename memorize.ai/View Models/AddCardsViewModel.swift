import Combine
import LoadingState

final class AddCardsViewModel: ViewModel {
	let deck: Deck
	
	@Published var cards = [Card]()
	
	@Published var publishLoadingState = LoadingState()
	
	init(deck: Deck) {
		self.deck = deck
	}
	
	var isPublishButtonDisabled: Bool {
		false // TODO: Change this
	}
	
	func publish() {
		// TODO: Publish cards
	}
}

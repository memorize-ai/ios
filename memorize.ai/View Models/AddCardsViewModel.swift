import Combine
import LoadingState

final class AddCardsViewModel: ViewModel {
	let deck: Deck
	
	@Published var cards = [Card.Draft]()
	
	@Published var publishLoadingState = LoadingState()
	
	init(deck: Deck) {
		self.deck = deck
	}
	
	var isPublishButtonDisabled: Bool {
		false // TODO: Change this
	}
	
	func removeCard(_ card: Card.Draft) {
		cards.removeAll { $0 == card }
	}
	
	func publish() {
		// TODO: Publish cards
	}
}

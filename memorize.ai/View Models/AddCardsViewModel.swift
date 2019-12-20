import Combine
import LoadingState

final class AddCardsViewModel: ViewModel {
	let deck: Deck
	
	@Published var cards = [Card.Draft]()
	
	@Published var cardsLoadingState = LoadingState()
	@Published var publishLoadingState = LoadingState()
	
	init(deck: Deck, user: User) {
		self.deck = deck
		
		cardsLoadingState.startLoading()
		deck.loadCardDrafts(forUser: user).done {
			self.cards = $0
			self.cardsLoadingState.succeed()
		}.catch { error in
			self.cardsLoadingState.fail(error: error)
		}
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

import Combine
import LoadingState

final class AddCardsViewModel: ViewModel {
	let deck: Deck
	
	@Published var cards = [Card.Draft]()
	
	@Published var cardsLoadingState = LoadingState()
	@Published var publishLoadingState = LoadingState()
	
	init(deck: Deck, user: User) {
		self.deck = deck.loadSections()
		
		cardsLoadingState.startLoading()
		deck.loadCardDrafts(forUser: user).done { cards in
			self.cards = cards.map { card in
				card.onChange = {
					self.cardDidChange(card)
				}
				return card
			}
			self.cardsLoadingState.succeed()
		}.catch { error in
			self.cardsLoadingState.fail(error: error)
		}
	}
	
	var isPublishButtonDisabled: Bool {
		false // TODO: Change this
	}
	
	func cardDidChange(_ card: Card.Draft) {
		// TODO: Handle card change
	}
	
	func removeCard(_ card: Card.Draft) {
		cards.removeAll { $0 == card }
	}
	
	func publish() {
		// TODO: Publish cards
	}
}

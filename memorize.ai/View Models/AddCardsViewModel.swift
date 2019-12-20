import Combine
import PromiseKit
import LoadingState

final class AddCardsViewModel: ViewModel {
	let deck: Deck
	let user: User
	
	@Published var cards = [Card.Draft]()
	
	@Published var cardsLoadingState = LoadingState()
	@Published var publishLoadingState = LoadingState()
	
	init(deck: Deck, user: User) {
		self.deck = deck.loadSections()
		self.user = user
		
		cardsLoadingState.startLoading()
		deck.loadCardDrafts(forUser: user).done { cards in
			for card in cards {
				card.onChange = {
					self.cardDidChange(card)
				}
			}
			self.cards = cards.isEmpty
				? [.init(parent: deck)]
				: cards
			self.cardsLoadingState.succeed()
		}.catch { error in
			self.cardsLoadingState.fail(error: error)
		}
	}
	
	var isPublishButtonDisabled: Bool {
		for card in cards {
			if card.isPublishable {
				return false
			}
		}
		return true
	}
	
	func cardDidChange(_ card: Card.Draft) {
		guard cards.last == card && !card.isEmpty else { return }
		cards.append(.init(
			parent: deck,
			sectionId: card.sectionId
		))
	}
	
	func removeCard(_ card: Card.Draft) {
		cards.removeAll { $0 == card }
		if cards.isEmpty {
			cards = [.init(parent: deck)]
		}
	}
	
	var publishCardsPromiseArray: [Promise<Void>] {
		cards.map { card in
			guard card.isPublishable else { return .init() }
			card.publishLoadingState.startLoading()
			return card.publishAsNew().done { _ in
				self.cards.removeAll { $0 == card }
				card.removeDraft(forUser: self.user)
				card.publishLoadingState.succeed()
			}
		}
	}
	
	func publish(onDone: (() -> Void)? = nil) {
		publishLoadingState.startLoading()
		when(fulfilled: publishCardsPromiseArray).done {
			self.publishLoadingState.succeed()
			if self.cards.isEmpty {
				onDone?()
			}
		}.catch { error in
			self.publishLoadingState.fail(error: error)
		}
	}
}

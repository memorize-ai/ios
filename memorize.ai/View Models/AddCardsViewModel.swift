import Combine
import PromiseKit
import LoadingState

final class AddCardsViewModel: ViewModel {
	let deck: Deck
	let user: User
	
	@Published var cards = [Card.Draft]()
	
	@Published var isRemoveDraftPopUpShowing = false
	@Published var isAddSectionPopUpShowing = false
	
	@Published var cardsLoadingState = LoadingState()
	@Published var publishLoadingState = LoadingState()
	
	var currentCard: Card.Draft?
	
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
				? self.initialCards
				: cards
			self.cardsLoadingState.succeed()
		}.catch { error in
			self.cardsLoadingState.fail(error: error)
		}
	}
	
	var initialCards: [Card.Draft] {
		let card = Card.Draft(parent: deck)
		card.onChange = {
			self.cardDidChange(card)
		}
		return [card]
	}
	
	var isPublishButtonDisabled: Bool {
		for card in cards {
			if card.isPublishable {
				return false
			}
		}
		return true
	}
	
	var hasDraft: Bool {
		for card in cards {
			if !card.isEmpty {
				return true
			}
		}
		return false
	}
	
	func cardDidChange(_ card: Card.Draft) {
		_ = card.isEmpty
			? card.removeDraft(forUser: user)
			: card.updateDraft(forUser: user)
		guard cards.last == card && !card.isEmpty else { return }
		let newCard = Card.Draft(
			parent: deck,
			sectionId: card.sectionId
		)
		newCard.onChange = {
			self.cardDidChange(newCard)
		}
		cards.append(newCard)
	}
	
	func removeCard(_ card: Card.Draft) {
		cards.removeAll { $0 == card }
		card.removeDraft(forUser: user)
		if cards.isEmpty {
			cards = initialCards
		}
	}
	
	@discardableResult
	func removeAllDrafts() -> Promise<[Void]> {
		user.documentReference
			.collection("decks/\(deck.id)/drafts")
			.getDocuments()
			.map { snapshot in
				snapshot.documents.map { document in
					document.reference.delete()
				}
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

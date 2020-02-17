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
	
	@Published var canPublish = false
	
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
			
			if cards.isEmpty {
				self.cards = self.initialCards
				self.canPublish = false
			} else {
				self.cards = cards
				self.resetCanPublish()
			}
			
			self.cardsLoadingState.succeed()
		}.catch { error in
			self.cardsLoadingState.fail(error: error)
		}
	}
	
	var hasDraft: Bool {
		!(cards.count == 1 && cards.first?.isEmpty ?? true)
	}
	
	var initialCards: [Card.Draft] {
		let card = Card.Draft(parent: deck)
		card.onChange = {
			self.cardDidChange(card)
		}
		return [card]
	}
	
	func resetCanPublish() {
		for card in cards {
			if card.isPublishable {
				canPublish = true
				return
			}
		}
		canPublish = false
	}
	
	func cardDidChange(_ card: Card.Draft) {
		_ = card.isEmpty
			? card.removeDraft(forUser: user)
			: card.updateDraft(forUser: user)
		
		resetCanPublish()
	}
	
	func addCard() {
		let card = Card.Draft(
			parent: deck,
			sectionId: cards.last?.sectionId
		)
		card.onChange = {
			self.cardDidChange(card)
		}
		cards.append(card)
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
		cards.compactMap { card in
			guard card.isPublishable else { return nil }
			card.publishLoadingState.startLoading()
			return card.publishAsNew(forUser: user).done { _ in
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
				self.cards = self.initialCards
				onDone?()
			}
		}.catch { error in
			self.publishLoadingState.fail(error: error)
		}
	}
}

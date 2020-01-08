import Combine
import FirebaseFirestore
import LoadingState

final class LearnViewModel: ViewModel {
	let deck: Deck
	let section: Deck.Section?
	
	let numberOfTotalCards: Int
	
	@Published var current: Card.LearnData?
	@Published var currentIndex = -1
	
	@Published var shouldShowRecap = false
	
	@Published var currentCardLoadingState = LoadingState()
	
	var cards = [Card.LearnData]()
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
		
		numberOfTotalCards = section?.numberOfCards ?? deck.numberOfCards
	}
	
	var currentCard: Card? {
		current?.parent
	}
	
	var numberOfMasteredCards: Int {
		cards.reduce(0) { acc, card in
			acc + *card.isMastered
		}
	}
	
	var numberOfSeenCards: Int {
		cards.count - numberOfMasteredCards
	}
	
	var numberOfUnseenCards: Int {
		numberOfTotalCards - cards.count
	}
	
	func loadNextCard() {
		currentIndex =
			currentIndex == numberOfTotalCards - 1 ? 0 : currentIndex + 1
		
		if let section = section {
			if let card = cards[safe: currentIndex] {
				current = card
			} else if let card = section.cards[safe: currentIndex] {
				let card = Card.LearnData(parent: card)
				cards.append(card)
				current = card
			} else {
				currentCardLoadingState.startLoading()
				
				var query = deck.documentReference
					.collection("cards")
					.whereField("section", isEqualTo: section.id)
				
				if let currentCardSnapshot = currentCard?.snapshot {
					query = query.start(afterDocument: currentCardSnapshot)
				}
				
				query
					.limit(to: 1)
					.getDocuments()
					.done { snapshot in
						if let document = snapshot.documents.first {
							let card = Card.LearnData(
								parent: .init(snapshot: document)
							)
							self.cards.append(card)
							self.current = card
						} else {
							self.shouldShowRecap = true
						}
						self.currentCardLoadingState.succeed()
					}
					.catch { error in
						print(error) // TODO: Handle error with alert
						self.currentCardLoadingState.fail(error: error)
					}
			}
		} else {
			
		}
	}
}

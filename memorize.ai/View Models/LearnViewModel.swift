import Combine
import FirebaseFirestore
import LoadingState

final class LearnViewModel: ViewModel {
	let deck: Deck
	let section: Deck.Section?
	
	let numberOfTotalCards: Int
	
	@Published var currentCard: Card?
	@Published var currentCardIndex = -1
	
	@Published var shouldShowRecap = false
	
	@Published var currentCardLoadingState = LoadingState()
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
		
		numberOfTotalCards = section?.numberOfCards ?? deck.numberOfCards
		
		loadNextCard()
	}
	
	var numberOfMasteredCards: Int {
		0 // TODO: Change this
	}
	
	var numberOfSeenCards: Int {
		0 // TODO: Change this
	}
	
	var numberOfUnseenCards: Int {
		0 // TODO: Change this
	}
	
	func loadNextCard() {
		currentCardIndex =
			currentCardIndex == numberOfTotalCards - 1 ? 0 : currentCardIndex + 1
		
		if let section = section {
			if let card = section.cards[safe: currentCardIndex] {
				currentCard = card
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
							let card = Card(snapshot: document)
							section.cards.append(card)
							self.currentCard = card
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

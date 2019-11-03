import Combine

final class RecommendedDecksViewModel: ViewModel {
	@Published var decks = [Deck]()
	
	var shouldLoadDecks = true
	
	func loadDecks() {
		shouldLoadDecks = false
		// TODO: Load decks
	}
}

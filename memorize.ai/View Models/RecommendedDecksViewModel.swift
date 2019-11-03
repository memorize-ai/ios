import Combine

final class RecommendedDecksViewModel: ViewModel {
	@Published var decks = [Deck]()
	@Published var decksLoadingState = LoadingState.none
	
	func loadDecks() {
		// TODO: Load decks
	}
}

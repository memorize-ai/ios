import Combine
import LoadingState

final class RecommendedDecksViewModel: ViewModel {
	@Published var decks = [Deck]()
	@Published var decksLoadingState = LoadingState()
	
	func loadDecks(topics: [String]) {
		decksLoadingState.startLoading()
		Deck.search(
			filterForTopics: topics.isEmpty ? nil : topics,
			sortBy: .top
		).done { decks in
			self.decks = decks
			self.decksLoadingState.succeed()
		}.catch { error in
			self.decksLoadingState.fail(error: error)
		}
	}
}

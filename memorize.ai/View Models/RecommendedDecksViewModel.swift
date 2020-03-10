import Combine
import LoadingState

final class RecommendedDecksViewModel: ViewModel {
	@Published var decks = [Deck]()
	@Published var decksLoadingState = LoadingState()
	
	func loadDecks(topics: [String]) {
		decksLoadingState.startLoading()
		onBackgroundThread {
			Deck.search(
				filterForTopics: topics.nilIfEmpty,
				sortBy: .top
			).done { decks in
				onMainThread {
					self.decks = decks
					self.decksLoadingState.succeed()
				}
			}.catch { error in
				onMainThread {
					self.decksLoadingState.fail(error: error)
				}
			}
		}
	}
}

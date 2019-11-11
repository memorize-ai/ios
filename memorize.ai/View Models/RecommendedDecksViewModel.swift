import Combine
import LoadingState

final class RecommendedDecksViewModel: ViewModel {
	@Published var decks = [Deck]()
	@Published var decksLoadingState = LoadingState()
	
	var loadedDecks = [String]()
	
	func loadDecks(interests: [String], topics: [Topic]) {
		decksLoadingState.startLoading()
		let maxDecksPerTopic = getMaxDecksPerTopic(
			numberOfInterests: interests.count
		)
		for topicId in interests {
			guard let topic = (topics.first {
				$0.id == topicId
			}) else { continue }
			for deckId in topic.topDecks.prefix(maxDecksPerTopic) where !didLoadDeck(id: deckId) {
				loadedDecks.append(deckId)
				loadDeck(id: deckId)
			}
		}
	}
	
	func loadDeck(id: String) {
		Deck.fromId(id).done { deck in
			self.decks.append(deck)
			self.decksLoadingState.succeed()
		}.catch { error in
			self.decksLoadingState.fail(error: error)
		}
	}
	
	func getMaxDecksPerTopic(numberOfInterests: Int) -> Int {
		numberOfInterests < 10
			? 30 / numberOfInterests
			: 3
	}
	
	func didLoadDeck(id: String) -> Bool {
		loadedDecks.contains(id)
	}
}

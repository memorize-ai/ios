import Combine

final class RecommendedDecksViewModel: ViewModel {
	@Published var decks = [Deck]()
	@Published var decksLoadingState = LoadingState.none
	
	func loadDecks(interests: [String], topics: [Topic]) {
		decksLoadingState = .loading()
		let maxDecksPerTopic = getMaxDecksPerTopic(
			numberOfInterests: interests.count
		)
		for topicId in interests {
			if decksLoadingState.didFail { return }
			guard let topic = (topics.first {
				$0.id == topicId
			}) else { continue }
			for deckId in topic.topDecks.prefix(maxDecksPerTopic) {
				if decksLoadingState.didFail { return }
				loadDeck(id: deckId)
			}
		}
	}
	
	func loadDeck(id: String) {
		Deck.fromId(id).done { deck in
			self.decks.append(deck.loadImage())
			self.decksLoadingState = .success()
		}.catch { error in
			self.decksLoadingState = .failure(
				message: error.localizedDescription
			)
		}
	}
	
	func getMaxDecksPerTopic(numberOfInterests: Int) -> Int {
		3 // TODO: Calculate this dynamically
	}
}

import Combine
import PromiseKit

final class RecommendedDecksViewModel: ViewModel {
	static let maxDecksPerTopic = 3
	
	let currentUserStore: UserStore
	
	@Published var decks = [Deck]()
	@Published var decksLoadingState = LoadingState.none
	
	init(currentUserStore: UserStore) {
		self.currentUserStore = currentUserStore
	}
	
	func loadDecks() {
		decksLoadingState = .loading()
		for topicId in currentUserStore.user.interests {
			if decksLoadingState.didFail { return }
			guard let topic = (currentUserStore.topics.first {
				$0.id == topicId
			}) else { continue }
			for deckId in topic.topDecks.prefix(Self.maxDecksPerTopic) {
				if decksLoadingState.didFail { return }
				Deck.fromId(deckId).done { deck in
					self.decks.append(deck.loadImage())
					self.decksLoadingState = .success()
				}.catch { error in
					self.decksLoadingState = .failure(
						message: error.localizedDescription
					)
				}
			}
		}
	}
}

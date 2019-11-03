import Combine
import PromiseKit

final class RecommendedDecksViewModel: ViewModel {
	let currentUser: User
	
	@Published var decks = [Deck]()
	@Published var decksLoadingState = LoadingState.none
	
	init(currentUser: User) {
		self.currentUser = currentUser
	}
	
	func loadDecks() {
		decksLoadingState = .loading()
		// TODO: Load decks
	}
	
	func getDeckIds() -> Promise<[String]> {
		.value([]) // TODO: Change this
	}
}

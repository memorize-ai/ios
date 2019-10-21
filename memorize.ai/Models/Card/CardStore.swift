import Combine

final class CardStore: ObservableObject {
	@Published var cards: [Card]
	@Published var loadingState = LoadingState.default
	
	init(_ cards: [Card] = []) {
		self.cards = cards
	}
}

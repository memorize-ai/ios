import Combine

final class CardStore: ObservableObject {
	@Published var cards: [Card]
	@Published var loadingState = LoadingState.default
	
	init(_ cards: [Card] = []) {
		self.cards = cards
	}
	
	@discardableResult
	func prepareForUpdate() -> Self {
		objectWillChange.send()
		return self
	}
}

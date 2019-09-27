import Combine

final class DeckStore: ObservableObject {
	@Published var decks: [Deck]
	
	init(_ decks: [Deck] = []) {
		self.decks = decks
	}
}

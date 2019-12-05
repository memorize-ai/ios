import Combine

final class PublishDeckViewModel: ObservableObject {
	let deck: Deck?
	
	@Published var name: String
	@Published var subtitle: String
	@Published var description: String
	
	init(deck: Deck? = nil) {
		self.deck = deck
		name = deck?.name ?? ""
		subtitle = deck?.subtitle ?? ""
		description = deck?.description ?? ""
	}
}

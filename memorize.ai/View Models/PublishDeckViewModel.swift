import SwiftUI

final class PublishDeckViewModel: ObservableObject {
	let deck: Deck?
	
	@Published var image: Image?
	@Published var name: String
	@Published var subtitle: String
	@Published var description: String
	
	init(deck: Deck? = nil) {
		self.deck = deck
		image = deck?.image
		name = deck?.name ?? ""
		subtitle = deck?.subtitle ?? ""
		description = deck?.description ?? ""
	}
	
	func publish() {
		// TODO: Publish deck
	}
}

import SwiftUI

struct EditCardViewNavigationLink<Label: View>: View {
	let deck: Deck
	let card: Card
	let label: Label
	
	init(deck: Deck, card: Card, label: () -> Label) {
		self.deck = deck
		self.card = card
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: EditCardView()
				.environmentObject(EditCardViewModel())
				.environmentObject(Card.Draft(
					parent: deck,
					card: card
				))
				.removeNavigationBar()
		) {
			label
		}
	}
}

#if DEBUG
struct EditCardViewNavigationLink_Previews: PreviewProvider {
	static var previews: some View {
		EditCardViewNavigationLink(
			deck: PREVIEW_CURRENT_STORE.user.decks[0],
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
		) {
			Text("Edit card")
		}
	}
}
#endif

import SwiftUI

struct EditCardViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
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
			destination: EditCardView(card: .init(
				parent: deck,
				card: card
			))
			.environmentObject(currentStore)
			.environmentObject(EditCardViewModel())
			.navigationBarRemoved()
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

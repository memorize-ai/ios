import SwiftUI

struct AddCardsViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let deck: Deck
	let label: Label
	
	init(deck: Deck, label: () -> Label) {
		self.deck = deck
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: AddCardsView<EmptyView>(destination: nil)
				.environmentObject(currentStore)
				.environmentObject(AddCardsViewModel(
					deck: deck,
					user: currentStore.user
				))
				.navigationBarRemoved()
		) {
			label
		}
	}
}

#if DEBUG
struct AddCardsViewNavigationLink_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsViewNavigationLink(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		) {
			Text("Add cards")
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

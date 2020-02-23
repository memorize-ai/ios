import SwiftUI

struct CramViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let deck: Deck
	let section: Deck.Section?
	let label: Label
	
	init(
		deck: Deck,
		label: () -> Label
	) {
		self.deck = deck
		section = nil
		self.label = label()
	}
	
	init(
		section: Deck.Section,
		label: () -> Label
	) {
		deck = section.parent
		self.section = section
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: CramView(deck: deck, section: section)
				.environmentObject(currentStore)
				.navigationBarRemoved()
		) {
			label
		}
	}
}

#if DEBUG
struct CramViewNavigationLink_Previews: PreviewProvider {
	static var previews: some View {
		CramViewNavigationLink(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		) {
			Text("Cram")
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

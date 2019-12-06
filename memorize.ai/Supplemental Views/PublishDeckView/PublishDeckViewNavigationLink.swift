import SwiftUI

struct PublishDeckViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let deck: Deck?
	let label: Label
	
	init(deck: Deck? = nil, label: () -> Label) {
		self.deck = deck
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: PublishDeckView(deck: deck)
				.environmentObject(currentStore)
				.removeNavigationBar()
		) {
			label
		}
	}
}

#if DEBUG
struct PublishDeckViewNavigationLink_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckViewNavigationLink {
			Text("Create deck")
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

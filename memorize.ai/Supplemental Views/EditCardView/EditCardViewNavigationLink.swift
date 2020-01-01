import SwiftUI

struct EditCardViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let card: Card
	let label: Label
	
	init(card: Card, label: () -> Label) {
		self.card = card
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: EditCardView()
				.environmentObject(currentStore)
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
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
		) {
			Text("Edit card")
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

import SwiftUI

struct EditCardViewNavigationLink<Label: View>: View {
	let card: Card
	let label: Label
	
	init(card: Card, label: () -> Label) {
		self.card = card
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: EditCardView()
				.environmentObject(card)
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
	}
}
#endif

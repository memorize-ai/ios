import SwiftUI

struct ReviewViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let deck: Deck?
	let section: Deck.Section?
	let label: Label
	
	init(
		deck: Deck?,
		section: Deck.Section?,
		label: () -> Label
	) {
		self.deck = deck
		self.section = section
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: ReviewView()
				.environmentObject(currentStore)
				.environmentObject(ReviewViewModel(
					user: currentStore.user,
					deck: deck,
					section: section
				))
		) {
			label
		}
	}
}

#if DEBUG
struct ReviewViewNavigationLink_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewNavigationLink(deck: nil, section: nil) {
			Text("Review")
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

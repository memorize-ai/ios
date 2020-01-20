import SwiftUI

struct ReviewViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let deck: Deck?
	let section: Deck.Section?
	let label: Label
	
	init(label: () -> Label) {
		deck = nil
		section = nil
		self.label = label()
	}
	
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
			destination: ReviewView(
				user: currentStore.user,
				deck: deck,
				section: section
			)
			.environmentObject(currentStore)
			.navigationBarRemoved()
		) {
			label
		}
	}
}

#if DEBUG
struct ReviewViewNavigationLink_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewNavigationLink {
			Text("Review")
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

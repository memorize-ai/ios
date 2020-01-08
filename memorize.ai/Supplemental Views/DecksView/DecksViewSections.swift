import SwiftUI

struct DecksViewSections: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var selectedDeck: Deck
	
	var sections: [Deck.Section] {
		(selectedDeck.hasUnsectionedCards
			? [selectedDeck.unsectionedSection]
			: []) +
		selectedDeck.sections
	}
	
	var body: some View {
		VStack(spacing: 16) {
			ForEach(sections) { section in
				VStack {
					DecksViewSectionHeader(section: section)
						.onTapGesture {
							self.model.toggleSectionExpanded(
								section,
								forUser: self.currentStore.user
							)
						}
					DecksViewSectionBody(section: section)
				}
			}
		}
	}
}

#if DEBUG
struct DecksViewSections_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSections(
			selectedDeck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
		.environmentObject(DecksViewModel())
	}
}
#endif

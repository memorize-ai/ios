import SwiftUI

struct DecksViewSections: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var selectedDeck: Deck
	
	var sections: [Deck.Section] {
		(selectedDeck.hasUnsectionedCards
			? [selectedDeck.unsectionedSection]
			: []
		) +
		selectedDeck.sections
	}
	
	var sectionCountMessage: String {
		let extraCount = sections.count - MAX_NUMBER_OF_VIEWABLE_SECTIONS
		return "\(extraCount.formatted) more section\(extraCount == 1 ? "" : "s")..."
	}
	
	var body: some View {
		VStack(spacing: 16) {
			ForEach(sections.prefix(MAX_NUMBER_OF_VIEWABLE_SECTIONS)) { section in
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
			if sections.count > MAX_NUMBER_OF_VIEWABLE_SECTIONS {
				Text(sectionCountMessage)
					.font(.muli(.bold, size: 15))
					.foregroundColor(.darkGray)
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

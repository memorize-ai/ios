import SwiftUI

struct DecksViewSections: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var selectedDeck: Deck
	
	@Binding var selectedSection: Deck.Section?
	@Binding var isSectionOptionsPopUpShowing: Bool
	
	let isSectionExpanded: (Deck.Section) -> Bool
	let toggleSectionExpanded: (Deck.Section, User) -> Void
	
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
		LazyVStack(spacing: 16) {
			ForEach(sections.prefix(MAX_NUMBER_OF_VIEWABLE_SECTIONS)) { section in
				VStack {
					DecksViewSectionHeader(
						section: section,
						selectedSection: self.$selectedSection,
						isSectionOptionsPopUpShowing: self.$isSectionOptionsPopUpShowing,
						isSectionExpanded: self.isSectionExpanded,
						toggleSectionExpanded: self.toggleSectionExpanded
					)
					.onTapGesture {
						self.toggleSectionExpanded(section, self.currentStore.user)
					}
					DecksViewSectionBody(
						section: section,
						isSectionExpanded: self.isSectionExpanded
					)
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
			selectedDeck: PREVIEW_CURRENT_STORE.user.decks.first!,
			selectedSection: .constant(nil),
			isSectionOptionsPopUpShowing: .constant(false),
			isSectionExpanded: { _ in true },
			toggleSectionExpanded: { _, _ in }
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

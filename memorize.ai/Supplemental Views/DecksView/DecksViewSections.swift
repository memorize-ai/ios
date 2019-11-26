import SwiftUI

struct DecksViewSections: View {
	@ObservedObject var selectedDeck: Deck
	
	var body: some View {
		ForEach(selectedDeck.sections) { section in
			VStack {
				DecksViewSectionHeader(section: section)
				DecksViewSectionBody(section: section)
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

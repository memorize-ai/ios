import SwiftUI

struct DecksViewSections: View {
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var selectedDeck: Deck
	
	var body: some View {
		ForEach(selectedDeck.sections) { section in
			DecksViewSectionHeader(
				deck: self.selectedDeck,
				section: section
			)
		}
	}
}

#if DEBUG
struct DecksViewSections_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSections(
			selectedDeck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
		.environmentObject(DecksViewModel())
	}
}
#endif

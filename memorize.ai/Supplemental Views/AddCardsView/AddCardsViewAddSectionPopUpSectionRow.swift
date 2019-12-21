import SwiftUI

struct AddCardsViewAddSectionPopUpSectionRow: View {
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		Text("Hello, World!")
	}
}

#if DEBUG
struct AddCardsViewAddSectionPopUpSectionRow_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsViewAddSectionPopUpSectionRow(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0]
		)
	}
}
#endif

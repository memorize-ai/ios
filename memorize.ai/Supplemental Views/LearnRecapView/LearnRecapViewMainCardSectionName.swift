import SwiftUI

struct LearnRecapViewMainCardSectionName: View {
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		Text(section.name)
	}
}

#if DEBUG
struct LearnRecapViewMainCardSectionName_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewMainCardSectionName(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0]
		)
	}
}
#endif

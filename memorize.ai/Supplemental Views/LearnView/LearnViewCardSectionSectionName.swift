import SwiftUI

struct LearnViewCardSectionSectionName: View {
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		Group {
			Text("|")
				.foregroundColor(Color.white.opacity(0.36))
			Text(section.name)
				.foregroundColor(.white)
				.shrinks()
		}
	}
}

#if DEBUG
struct LearnViewCardSectionSectionName_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewCardSectionSectionName(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0]
		)
	}
}
#endif

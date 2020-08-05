import SwiftUI

struct CramViewCardSectionSectionName: View {
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		Group {
			Text("|")
				.foregroundColor(Color.white.opacity(0.36))
			Text(section.name)
				.foregroundColor(.white)
		}
		.lineLimit(1)
		.layoutPriority(100)
	}
}

#if DEBUG
struct CramViewCardSectionSectionName_Previews: PreviewProvider {
	static var previews: some View {
		CramViewCardSectionSectionName(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0]
		)
	}
}
#endif

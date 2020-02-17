import SwiftUI

struct CramRecapViewMainCardSectionName: View {
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		Text(section.name)
			.font(.muli(.extraBold, size: 18))
			.foregroundColor(.darkGray)
			.shrinks(withLineLimit: 3)
			.padding(.top, 6)
	}
}

#if DEBUG
struct CramRecapViewMainCardSectionName_Previews: PreviewProvider {
	static var previews: some View {
		CramRecapViewMainCardSectionName(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0]
		)
	}
}
#endif

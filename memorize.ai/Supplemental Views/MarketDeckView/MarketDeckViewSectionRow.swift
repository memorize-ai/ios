import SwiftUI

struct MarketDeckViewSectionRow: View {
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		HStack {
			Text(section.name)
				.font(.muli(.semiBold, size: 17))
			Rectangle()
				.foregroundColor(literal: #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1))
				.frame(height: 1)
			Text("(\(section.numberOfCards.formatted) card\(section.numberOfCards == 1 ? "" : "s"))")
				.font(.muli(.regular, size: 17))
				.foregroundColor(.lightGrayText)
		}
	}
}

#if DEBUG
struct MarketDeckViewSectionRow_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewSectionRow(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0]
		)
	}
}
#endif

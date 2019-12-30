import SwiftUI

struct DecksViewOrderSectionsSheetViewSectionRow: View {
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		HStack {
			Text(section.name)
				.font(.muli(.bold, size: 17))
				.foregroundColor(.darkGray)
			Rectangle()
				.foregroundColor(.lightGrayBorder)
				.frame(height: 1)
			Text("(\(section.numberOfCards.formatted))")
				.font(.muli(.semiBold, size: 17))
				.foregroundColor(.darkGray)
		}
		.padding(.leading, -40)
	}
}

#if DEBUG
struct DecksViewOrderSectionsSheetViewSectionRow_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewOrderSectionsSheetViewSectionRow(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0]
		)
	}
}
#endif

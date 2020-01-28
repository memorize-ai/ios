import SwiftUI

struct ReviewRecapViewSectionPerformanceRowSectionCellDeckName: View {
	@ObservedObject var deck: Deck
	
	var body: some View {
		Text(deck.name)
			.font(.muli(.bold, size: 17))
			.foregroundColor(.lightGrayText)
	}
}

#if DEBUG
struct ReviewRecapViewSectionPerformanceRowSectionCellDeckName_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewSectionPerformanceRowSectionCellDeckName(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif

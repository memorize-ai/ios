import SwiftUI

struct MarketDeckViewSections: View {
	@EnvironmentObject var deck: Deck
	
	var body: some View {
		VStack {
			MarketDeckViewSectionTitle("Sections")
		}
	}
}

#if DEBUG
struct MarketDeckViewSections_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewSections()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

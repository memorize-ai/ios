import SwiftUI

struct MarketDeckViewInfo: View {
	@EnvironmentObject var deck: Deck
	
	var body: some View {
		VStack {
			MarketDeckViewSectionTitle("Info")
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				EmptyView() // TODO: Add content
			}
		}
	}
}

#if DEBUG
struct MarketDeckViewInfo_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewInfo()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

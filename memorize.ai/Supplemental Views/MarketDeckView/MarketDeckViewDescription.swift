import SwiftUI

struct MarketDeckViewDescription: View {
	@EnvironmentObject var deck: Deck
	
	var body: some View {
		Text(deck.description)
			.font(.muli(.regular, size: 17))
			.foregroundColor(.darkGray)
			.padding(.horizontal, 23)
	}
}

#if DEBUG
struct MarketDeckViewDescription_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewDescription()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

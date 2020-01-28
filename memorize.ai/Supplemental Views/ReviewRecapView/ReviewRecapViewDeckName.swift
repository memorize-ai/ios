import SwiftUI

struct ReviewRecapViewDeckName: View {
	@ObservedObject var deck: Deck
	
	var body: some View {
		Text(deck.name)
			.font(.muli(.extraBold, size: 23))
			.foregroundColor(.darkGray)
			.shrinks(withLineLimit: 3)
	}
}

#if DEBUG
struct ReviewRecapViewDeckName_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewDeckName(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif

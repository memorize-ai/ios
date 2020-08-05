import SwiftUI

struct ReviewViewCardSectionDeckName: View {
	@ObservedObject var deck: Deck

	var body: some View {
		Text(deck.name)
			.foregroundColor(.white)
			.lineLimit(1)
	}
}

#if DEBUG
struct ReviewViewCardSectionDeckName_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewCardSectionDeckName(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif

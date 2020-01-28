import SwiftUI

struct ReviewRecapViewScrollableDeckName: View {
	@ObservedObject var deck: Deck
	
	var body: some View {
		CustomRectangle(background: Color(#colorLiteral(red: 0.1411764706, green: 0.6078431373, blue: 0.9725490196, alpha: 1)).opacity(0.08)) {
			Text(deck.name)
		}
	}
}

#if DEBUG
struct ReviewRecapViewScrollableDeckName_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewScrollableDeckName(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif

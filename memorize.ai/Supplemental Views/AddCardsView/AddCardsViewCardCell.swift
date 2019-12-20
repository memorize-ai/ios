import SwiftUI

struct AddCardsViewCardCell: View {
	@ObservedObject var card: Card
	
	var body: some View {
		Text("Hello, World!")
	}
}

#if DEBUG
struct AddCardsViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsViewCardCell(
			card: PREVIEW_CURRENT_STORE.user.decks[0].sections[0].cards[0]
		)
	}
}
#endif

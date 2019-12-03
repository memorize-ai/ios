import SwiftUI

struct MarketDeckViewCardPreviews: View {
	@EnvironmentObject var deck: Deck
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				ForEach(deck.previewCards) { card in
					Text(card.front)
				}
			}
			.padding(.horizontal, 23)
		}
		.onAppear {
			self.deck.loadPreviewCards()
		}
	}
}

#if DEBUG
struct MarketDeckViewCardPreviews_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewCardPreviews()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

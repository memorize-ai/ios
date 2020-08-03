import SwiftUI

struct MarketDeckViewCardPreviews: View {
	static let cellWidth = min(SCREEN_SIZE.width, 246)
	static let cellHeight = cellWidth * 354 / 246
	
	@EnvironmentObject var deck: Deck
	
	var cards: some View {
		ForEach(deck.previewCards) { card in
			CardPreviewCell(card: card)
				.frame(
					width: Self.cellWidth,
					height: Self.cellHeight
				)
		}
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			Group {
				if #available(iOS 14.0, *) {
					LazyHStack { cards }
				} else {
					HStack { cards }
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

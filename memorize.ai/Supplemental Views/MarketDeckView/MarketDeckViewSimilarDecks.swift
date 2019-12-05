import SwiftUI

struct MarketDeckViewSimilarDecks: View {
	var body: some View {
		VStack(spacing: 16) {
			MarketDeckViewSectionTitle("Similar decks")
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				EmptyView() // TODO: Replace with content
			}
		}
		.padding(.horizontal, 23)
	}
}

#if DEBUG
struct MarketDeckViewSimilarDecks_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewSimilarDecks()
	}
}
#endif

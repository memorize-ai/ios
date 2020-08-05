import SwiftUI

struct MarketDeckViewSimilarDecks: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var deck: Deck
	
	@State var selectedDeck: Deck!
	@State var isDeckSelected = false
	
	var similarDecks: some View {
		ForEach(deck.similarDecks) { similarDeck in
			DeckCellWithGetButton(
				deck: similarDeck,
				user: self.currentStore.user,
				width: 180
			)
			.onTapGesture {
				self.selectedDeck = similarDeck
				self.isDeckSelected = true
			}
		}
	}
	
	var body: some View {
		VStack(spacing: 16) {
			MarketDeckViewSectionTitle("Similar decks")
				.padding(.horizontal, 23)
			ScrollView(.horizontal, showsIndicators: false) {
				TryLazyHStack(alignment: .top) { self.similarDecks }
					.padding(.horizontal, 23)
			}
			if isDeckSelected {
				NavigateTo(
					MarketDeckView()
						.environmentObject(selectedDeck),
					when: $isDeckSelected
				)
			}
		}
	}
}

#if DEBUG
struct MarketDeckViewSimilarDecks_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewSimilarDecks()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
		
	}
}
#endif

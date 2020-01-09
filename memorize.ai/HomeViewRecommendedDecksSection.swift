import SwiftUI

struct HomeViewRecommendedDecksSection: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@State var selectedDeck: Deck!
	@State var isDeckSelected = false
	
	var body: some View {
		VStack {
			if !currentStore.recommendedDecks.isEmpty {
				CustomRectangle(
					background: Color.lightGrayBackground.opacity(0.5)
				) {
					Text("Recommended decks")
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
						.padding(.horizontal, 8)
						.padding(.vertical, 4)
				}
				.alignment(.leading)
				.padding(.horizontal, 23)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(alignment: .top) {
						ForEach(currentStore.recommendedDecks) { deck in
							DeckCellWithGetButton(
								deck: deck,
								user: self.currentStore.user,
								width: 144
							)
							.onTapGesture {
								self.selectedDeck = deck
								self.isDeckSelected = true
							}
						}
					}
					.padding(.horizontal, 23)
				}
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
struct HomeViewRecommendedDecksSection_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewRecommendedDecksSection()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

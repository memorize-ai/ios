import SwiftUI

struct HomeViewRecommendedDecksSection: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		VStack {
			if !currentStore.recommendedDecks.isEmpty {
				Text("Recommended Decks")
					.font(.muli(.bold, size: 20))
					.foregroundColor(.darkGray)
					.align(to: .leading)
					.padding(.horizontal, 23)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(currentStore.recommendedDecks) { deck in
							DeckCellWithGetButton(
								deck: deck,
								user: self.currentStore.user,
								width: 144
							)
						}
					}
					.padding(.horizontal, 23)
				}
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

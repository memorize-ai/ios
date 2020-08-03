import SwiftUI

struct RecommendedDecksViewContent: View {
	static let cellSpacing: CGFloat = 20
	
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: RecommendedDecksViewModel
	
	var body: some View {
		VStack {
			if model.decksLoadingState.isLoading {
				ActivityIndicator(color: .white)
				Spacer()
			} else {
				ScrollView(showsIndicators: false) {
					LazyVStack(spacing: Self.cellSpacing) {
						ForEach(model.decks) { deck in
							DeckCellWithGetButton(
								deck: deck,
								user: self.currentStore.user,
								width: SCREEN_SIZE.width - MarketView.horizontalPadding * 2,
								imageHeight: IS_IPAD ? 240 : 120,
								titleFontSize: 17,
								hasOpenButton: false,
								shouldManuallyModifyDecks: true
							)
						}
					}
					.padding(.bottom, MarketView.horizontalPadding)
				}
			}
		}
		.onAppear {
			self.model.loadDecks(
				topics: self.currentStore.user.interests
			)
		}
	}
}

#if DEBUG
struct RecommendedDecksViewContent_Previews: PreviewProvider {
	static var previews: some View {
		RecommendedDecksViewContent()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(RecommendedDecksViewModel())
	}
}
#endif

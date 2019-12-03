import SwiftUI

struct MarketView: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 13
	static let verticalCellSpacing: CGFloat = 20
	static let horizontalPadding: CGFloat = 23
	
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: MarketViewModel
	
	@State var selectedDeck: Deck!
	@State var isDeckSelected = false
	
	var grid: some View {
		Grid(
			elements: model.searchResults.map { deck in
				DeckCellWithGetButton(
					deck: deck,
					user: currentStore.user,
					width: Self.deckCellWidth
				)
				.onTapGesture {
					self.selectedDeck = deck
					self.isDeckSelected = true
				}
			},
			columns: Self.numberOfColumns,
			horizontalSpacing: Self.horizontalCellSpacing,
			verticalSpacing: Self.verticalCellSpacing
		)
		.frame(maxWidth: SCREEN_SIZE.width - Self.horizontalPadding * 2)
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack(spacing: 20) {
					Group {
						MarketViewTopControls()
						MarketViewTopButtons()
					}
					.padding(.horizontal, Self.horizontalPadding)
					ScrollView(showsIndicators: false) {
						self.grid
					}
				}
				if self.isDeckSelected {
					NavigateTo(
						MarketDeckView()
							.environmentObject(self.selectedDeck),
						when: self.$isDeckSelected
					)
				}
			}
		}
		.onAppear(perform: self.model.loadSearchResults)
	}
}

#if DEBUG
struct MarketView_Previews: PreviewProvider {
	static var previews: some View {
		MarketView()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(MarketViewModel(
				currentUser: PREVIEW_CURRENT_STORE.user
			))
	}
}
#endif

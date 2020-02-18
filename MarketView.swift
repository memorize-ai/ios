import SwiftUI
import QGrid

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
		ScrollView(showsIndicators: false) {
			VStack(spacing: Self.verticalCellSpacing) {
				ForEach(model.searchResults) { deck in
					DeckCellWithGetButton(
						deck: deck,
						user: self.currentStore.user,
						width: SCREEN_SIZE.width - Self.horizontalPadding * 2,
						imageHeight: 120,
						titleFontSize: 17
					)
					.onTapGesture {
						self.selectedDeck = deck
						self.isDeckSelected = true
					}
				}
			}
		}
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
					if self.model.searchResultsLoadingState.isLoading {
						ActivityIndicator(color: .white)
						Spacer()
					} else {
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
		.onAppear {
			self.model.loadSearchResults()
		}
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

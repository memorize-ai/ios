import SwiftUI
import QGrid
import PromiseKit
import LoadingState

struct MarketView: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 13
	static let verticalCellSpacing: CGFloat = 20
	static let horizontalPadding: CGFloat = 23
	
	enum FilterPopUpSideBarSelection {
		case topics
		case rating
		case downloads
	}
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@State var selectedDeck: Deck! = nil
	@State var isDeckSelected = false
	
	@Binding var searchText: String
	@Binding var isSortPopUpShowing: Bool
	@Binding var isFilterPopUpShowing: Bool
	
	var searchResults: [Deck]
	var searchResultsLoadingState: LoadingState
	let loadSearchResults: (Bool) -> Void
	
	var grid: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: Self.verticalCellSpacing) {
				ForEach(searchResults) { deck in
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
			.padding(.bottom, Self.horizontalPadding)
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
						MarketViewTopControls(searchText: self.$searchText)
						MarketViewTopButtons(
							isSortPopUpShowing: self.$isSortPopUpShowing,
							isFilterPopUpShowing: self.$isFilterPopUpShowing
						)
					}
					.padding(.horizontal, Self.horizontalPadding)
					if self.searchResultsLoadingState.isLoading {
						ActivityIndicator(color: .white)
						Spacer()
					} else {
						self.grid
					}
				}
				if self.isDeckSelected {
					NavigateTo(
						MarketDeckView()
							.environmentObject(self.selectedDeck!),
						when: self.$isDeckSelected
					)
				}
			}
		}
		.onAppear {
			self.loadSearchResults(false)
		}
	}
}

#if DEBUG
struct MarketView_Previews: PreviewProvider {
	static var previews: some View {
		MarketView(
			searchText: .constant(""),
			isSortPopUpShowing: .constant(false),
			isFilterPopUpShowing: .constant(true),
			searchResults: [],
			searchResultsLoadingState: .none,
			loadSearchResults: { _ in }
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

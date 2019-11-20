import SwiftUI

struct MarketView: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 13
	static let verticalCellSpacing: CGFloat = 20
	static let horizontalPadding: CGFloat = 23
	
	@EnvironmentObject var currentStore: CurrentStore
	
	var grid: some View {
		Grid(
			elements: [].map { deck in // TODO: Change this to decks
				DeckCellWithGetButton(
					deck: deck,
					user: currentStore.user,
					width: Self.deckCellWidth
				)
			},
			columns: Self.numberOfColumns,
			horizontalSpacing: Self.horizontalCellSpacing,
			verticalSpacing: Self.verticalCellSpacing
		)
		.frame(maxWidth: SCREEN_SIZE.width - Self.horizontalPadding * 2)
	}
	
	var body: some View {
		ZStack(alignment: .top) {
			HomeViewTopGradient()
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 20) {
				MarketViewTopControls()
					.padding(.horizontal, Self.horizontalPadding)
				// TODO: Add buttons
				grid
			}
		}
	}
}

#if DEBUG
struct MarketView_Previews: PreviewProvider {
	static var previews: some View {
		MarketView()
	}
}
#endif

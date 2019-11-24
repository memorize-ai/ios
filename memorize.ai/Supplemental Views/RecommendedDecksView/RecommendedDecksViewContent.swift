import SwiftUI

struct RecommendedDecksViewContent: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 10
	static let verticalCellSpacing: CGFloat = 20
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var model = RecommendedDecksViewModel()
	
	var body: some View {
		ScrollView(showsIndicators: false) {
			Grid(
				elements: model.decks.map { deck in
					DeckCellWithGetButton(
						deck: deck,
						user: currentStore.user,
						width: Self.deckCellWidth,
						shouldManuallyModifyDecks: true
					)
				},
				columns: Self.numberOfColumns,
				horizontalSpacing: Self.horizontalCellSpacing,
				verticalSpacing: Self.verticalCellSpacing
			)
			.frame(maxWidth: SCREEN_SIZE.width - 32)
		}
		.onAppear {
			self.model.loadDecks(
				topics: self.currentStore.user.interests
			)
		}
	}
}

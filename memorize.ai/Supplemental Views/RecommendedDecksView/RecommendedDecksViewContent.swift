import SwiftUI
import QGrid

struct RecommendedDecksViewContent: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 10
	static let verticalCellSpacing: CGFloat = 20
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var model = RecommendedDecksViewModel()
	
	var body: some View {
		QGrid(
			model.decks,
			columns: Self.numberOfColumns,
			vSpacing: Self.verticalCellSpacing,
			hSpacing: Self.horizontalCellSpacing
		) { deck in
			DeckCellWithGetButton(
				deck: deck,
				user: self.currentStore.user,
				width: Self.deckCellWidth,
				shouldManuallyModifyDecks: true,
				shouldShowRemoveAlert: false
			)
		}
		.frame(maxWidth: SCREEN_SIZE.width - 32)
		.onAppear {
			self.model.loadDecks(
				topics: self.currentStore.user.interests
			)
		}
	}
}

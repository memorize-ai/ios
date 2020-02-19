import SwiftUI
import QGrid

struct RecommendedDecksViewContent: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 10
	static let verticalCellSpacing: CGFloat = 20
	
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: RecommendedDecksViewModel
	
	var body: some View {
		VStack {
			if model.decksLoadingState.isLoading {
				ActivityIndicator(color: .white)
				Spacer()
			} else {
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
				.padding(.bottom)
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

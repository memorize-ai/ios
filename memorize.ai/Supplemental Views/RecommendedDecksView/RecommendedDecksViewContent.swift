import SwiftUI
import QGrid

struct RecommendedDecksViewContent: View {
	static let cellWidth: CGFloat = 165
	static let cellSpacing: CGFloat = 10
	static let numberOfColumns = numberOfGridColumns(
		width: SCREEN_SIZE.width - 32,
		cellWidth: cellWidth,
		horizontalSpacing: cellSpacing
	)
	
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
					vSpacing: Self.cellSpacing,
					hSpacing: Self.cellSpacing
				) { deck in
					DeckCellWithGetButton(
						deck: deck,
						user: self.currentStore.user,
						width: Self.cellWidth,
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

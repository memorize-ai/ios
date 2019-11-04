import SwiftUI

struct TestView: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 10
	static let verticalCellSpacing: CGFloat = 20
	
	@EnvironmentObject var currentUserStore: UserStore
	
	@ObservedObject var model = TestViewModel()
	
	var body: some View {
		print("VIEW_DECKS_COUNT:", model.decks.count)
		return ScrollView {
			Grid(
				elements: model.decks.map { deck in
					DeckCellWithGetButton(
						deck: deck,
						width: Self.deckCellWidth,
						isLoading: false, // TODO: Change this
						onGetClick: {} // TODO: Change this
					)
				},
				columns: Self.numberOfColumns,
				horizontalSpacing: Self.horizontalCellSpacing,
				verticalSpacing: Self.verticalCellSpacing
			)
			.frame(maxWidth: SCREEN_SIZE.width - 32)
		}
		.onAppear {
			guard self.model.decksLoadingState.isNone else { return }
			self.model.loadDecks(
				interests: self.currentUserStore.user.interests,
				topics: self.currentUserStore.topics
			)
		}
	}
}

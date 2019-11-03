import SwiftUI

struct RecommendedDecksViewContent: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 10
	static let verticalCellSpacing: CGFloat = 20
	
	@EnvironmentObject var currentUserStore: UserStore
	
	@ObservedObject var model: RecommendedDecksViewModel
	
	init(currentUser: User) {
		model = .init(currentUser: currentUser)
	}
	
	var body: some View {
		ScrollView {
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
		}
		.onAppear {
			guard self.model.decksLoadingState.isNone else { return }
			self.model.loadDecks()
		}
	}
}

#if DEBUG
struct RecommendedDecksViewContent_Previews: PreviewProvider {
	static var previews: some View {
		let currentUser = User(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com",
			interests: []
		)
		return RecommendedDecksViewContent(currentUser: currentUser)
			.environmentObject(UserStore(currentUser))
	}
}
#endif

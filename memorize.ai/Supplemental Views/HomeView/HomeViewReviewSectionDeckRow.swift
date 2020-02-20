import SwiftUI

struct HomeViewReviewSectionDeckRow: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var deck: Deck
	
	var body: some View {
		Button(action: {
			self.currentStore.goToDecksView(withDeck: self.deck)
		}) {
			HStack {
				Group {
					if deck.imageLoadingState.didFail {
						Image(systemName: .exclamationmarkTriangle)
							.foregroundColor(.gray)
							.scaleEffect(1.5)
					} else if deck.hasImage {
						if deck.image == nil {
							ActivityIndicator(color: .gray)
						} else {
							deck.displayImage?
								.resizable()
								.renderingMode(.original)
								.aspectRatio(contentMode: .fill)
						}
					} else {
						Deck.DEFAULT_IMAGE
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fill)
					}
				}
				.frame(width: 40, height: 40)
				.clipShape(Circle())
				Text(deck.name)
					.font(.muli(.bold, size: 16))
					.foregroundColor(.darkGray)
				Spacer()
				if deck.userData?.isDue ?? false {
					SideBarDeckRowDueCardsBadge(
						count: deck.userData?.numberOfDueCards ?? 0,
						isSelected: false
					)
				}
			}
			.padding(.horizontal)
			.padding(.vertical, 6)
		}
	}
}

#if DEBUG
struct HomeViewReviewSectionDeckRow_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewReviewSectionDeckRow(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

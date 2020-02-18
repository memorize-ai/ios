import SwiftUI

struct HomeViewReviewSection: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var user: User
	
	var deckList: some View {
		VStack(spacing: 0) {
			ForEach(user.decks.filter { $0.userData?.isDue ?? false }) { deck in
				Button(action: {
					self.currentStore.goToDecksView(withDeck: deck)
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
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white.opacity(0.8),
			borderColor: .lightGrayBorder,
			borderWidth: 1,
			shadowRadius: 5
		) {
			VStack {
				VStack {
					Text("Hello, \(user.name)")
						.font(.muli(.bold, size: 20))
						.alignment(.leading)
					Text("You have \(user.numberOfDueCards.nilIfZero?.formatted ?? "no") card\(user.numberOfDueCards == 1 ? "" : "s") due")
						.font(.muli(.bold, size: 15))
						.foregroundColor(.darkGray)
						.alignment(.leading)
						.padding(.top, 8)
						.padding(.bottom, 6)
					if user.numberOfDueCards > 0 {
						ReviewViewNavigationLink {
							CustomRectangle(
								background: { () -> Color in
									let count = self.user.numberOfDueCards
									if count < 10 { return .neonGreen }
									if count < 100 { return .neonOrange }
									return .neonRed
								}(),
								cornerRadius: 14
							) {
								Text("REVIEW")
									.font(.muli(.bold, size: 12))
									.foregroundColor(.white)
									.frame(width: 92, height: 28)
							}
						}
						.alignment(.leading)
					}
				}
				.padding([.horizontal, .top])
				deckList
					.padding(.bottom, 8)
			}
		}
		.padding(.horizontal, 23)
		.padding(.bottom, 10)
	}
}

#if DEBUG
struct HomeViewReviewSection_Previews: PreviewProvider {
	static var previews: some View {
		return HomeViewReviewSection(
			user: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

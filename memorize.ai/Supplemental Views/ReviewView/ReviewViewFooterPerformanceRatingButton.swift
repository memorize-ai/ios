import SwiftUI

struct ReviewViewFooterPerformanceRatingButton: View {
	let rateCurrentCard: (Card.PerformanceRating) -> Void
	let current: Card.ReviewData?
		
	let rating: Card.PerformanceRating
	
	var body: some View {
		Button(action: {
			self.rateCurrentCard(self.rating)
			playHaptic()
		}) {
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5
			) {
				VStack {
					Spacer()
					HStack {
						Text(rating.emoji)
						Text(rating.title.uppercased())
							.foregroundColor(.darkGray)
							.shrinks()
					}
					.font(.muli(.extraBold, size: 14))
					Spacer()
					CustomRectangle(background: rating.badgeColor.opacity(0.16)) {
						Group {
							if current == nil {
								ActivityIndicator(radius: 5, color: .darkGray)
									.frame(width: (SCREEN_SIZE.width - 8 * 4) / 8)
							} else {
								ReviewViewFooterPerformanceRatingButtonBadgeContent(
									reviewData: current!,
									rating: rating
								)
							}
						}
						.frame(height: 20)
					}
					.padding(.bottom, 6)
				}
				.padding(.horizontal)
				.frame(
					width: (SCREEN_SIZE.width - 8 * 4) / 3,
					height: 64
				)
			}
		}
	}
}

#if DEBUG
struct ReviewViewFooterPerformanceRatingButton_Previews: PreviewProvider {
	static var previews: some View {
		let model = ReviewViewModel(
			user: PREVIEW_CURRENT_STORE.user,
			deck: nil,
			section: nil
		)
		model.current = .init(
			parent: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
			isNew: true
		)
		return Text("")
			.environmentObject(model)
	}
}
#endif

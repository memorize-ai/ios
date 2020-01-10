import SwiftUI

struct ReviewViewFooterPerformanceRatingButton: View {
	@EnvironmentObject var model: ReviewViewModel
		
	let rating: Card.PerformanceRating
	
	var body: some View {
		Button(action: {
			self.model.rateCurrentCard(withRating: self.rating)
			playHaptic()
		}) {
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5
			) {
				HStack {
					Text(rating.emoji)
					Text(rating.title.uppercased())
						.font(.muli(.bold, size: 14))
						.foregroundColor(.darkGray)
						.shrinks()
					CustomRectangle(background: rating.badgeColor.opacity(0.16)) {
						Group {
							if model.current == nil {
								ActivityIndicator(radius: 1)
							} else {
								ReviewViewFooterPerformanceRatingButtonBadgeContent(
									reviewData: model.current!,
									rating: rating
								)
							}
						}
					}
				}
				.padding(.horizontal)
				.frame(
					width: (SCREEN_SIZE.width - 8 * 4) / 3,
					height: 44
				)
			}
		}
	}
}

#if DEBUG
struct ReviewViewFooterPerformanceRatingButton_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewFooterPerformanceRatingButton(rating: .easy)
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif

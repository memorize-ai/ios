import SwiftUI

struct ReviewViewFooterPerformanceRatingButton: View {
	@EnvironmentObject var model: ReviewViewModel
		
	let rating: Card.PerformanceRating
	
	var badgeColor: Color {
		switch rating {
		case .easy:
			return .neonGreen
		case .struggled:
			return .init(#colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1))
		case .forgot:
			return .init(#colorLiteral(red: 0.9607843137, green: 0.3647058824, blue: 0.137254902, alpha: 1))
		}
	}
	
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
					CustomRectangle(background: badgeColor.opacity(0.16)) {
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
						.padding(.horizontal, 2)
						.padding(.vertical, 1)
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

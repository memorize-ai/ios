import SwiftUI

struct ReviewViewFooter: View {
	@EnvironmentObject var model: ReviewViewModel
	
	func ratingButton(
		forRating rating: Card.PerformanceRating,
		dueDate: Date,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
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
					Text("+\(Date().compare(against: dueDate).split(separator: " ").dropFirst().joined())")
				}
				.padding(.horizontal)
				.frame(
					width: (SCREEN_SIZE.width - 8 * 4) / 3,
					height: 44
				)
			}
		}
	}
	
	var body: some View {
		ZStack {
//			HStack {
//				self.ratingButton(forRating: .easy) {
//					self.model.rateCurrentCard(withRating: .easy)
//					playHaptic()
//				}
//				self.ratingButton(forRating: .struggled) {
//					self.model.rateCurrentCard(withRating: .struggled)
//					playHaptic()
//				}
//				self.ratingButton(forRating: .forgot) {
//					self.model.rateCurrentCard(withRating: .forgot)
//					playHaptic()
//				}
//			}
//			.offset(x: model.isWaitingForRating ? 0 : -SCREEN_SIZE.width)
			Text("Tap anywhere to continue")
				.font(.muli(.bold, size: 17))
				.foregroundColor(.darkGray)
				.offset(x: model.isWaitingForRating ? SCREEN_SIZE.width : 0)
		}
	}
}

#if DEBUG
struct ReviewViewFooter_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewFooter()
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif

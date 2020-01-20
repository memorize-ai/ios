import SwiftUI

struct ReviewViewFooter: View {
	let rateCurrentCard: (Card.PerformanceRating) -> Void
	let current: Card.ReviewData?
	let isWaitingForRating: Bool
	
	var body: some View {
		ZStack {
			HStack {
				ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
					ReviewViewFooterPerformanceRatingButton(rateCurrentCard: self.rateCurrentCard, current: self.current, rating: rating)
				}
			}
			.offset(x: isWaitingForRating ? 0 : -SCREEN_SIZE.width)
			Text("Tap anywhere to continue")
				.font(.muli(.bold, size: 17))
				.foregroundColor(.darkGray)
				.offset(x: isWaitingForRating ? SCREEN_SIZE.width : 0)
		}
	}
}

#if DEBUG
struct ReviewViewFooter_Previews: PreviewProvider {
	static var previews: some View {
		Text("")
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif

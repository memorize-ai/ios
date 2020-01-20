import SwiftUI

struct ReviewViewFooter: View {
	let current: Card.ReviewData?
	let isWaitingForRating: Bool
	let rateCurrentCard: (Card.PerformanceRating) -> Void
	
	var body: some View {
		ZStack {
			HStack {
				ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
					ReviewViewFooterPerformanceRatingButton(
						current: self.current,
						rating: rating,
						rateCurrentCard: self.rateCurrentCard
					)
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
		ReviewViewFooter(current: nil, isWaitingForRating: true, rateCurrentCard: { _ in })
	}
}
#endif

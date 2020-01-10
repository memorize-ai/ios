import SwiftUI

struct ReviewViewFooter: View {
	@EnvironmentObject var model: ReviewViewModel
	
	var body: some View {
		ZStack {
			HStack {
				ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
					ReviewViewFooterPerformanceRatingButton(rating: rating)
				}
			}
			.offset(x: model.isWaitingForRating ? 0 : -SCREEN_SIZE.width)
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

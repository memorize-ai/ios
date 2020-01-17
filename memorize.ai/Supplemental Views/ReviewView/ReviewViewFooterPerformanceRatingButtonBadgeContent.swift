import SwiftUI

struct ReviewViewFooterPerformanceRatingButtonBadgeContent: View {
	@ObservedObject var reviewData: Card.ReviewData
	
	let rating: Card.PerformanceRating
	
	var text: String? {
		reviewData.predictionMessageForRating(rating)
	}
	
	var body: some View {
		Group {
			if text == nil {
				ActivityIndicator(radius: 5, color: .darkGray)
					.frame(width: (SCREEN_SIZE.width - 8 * 4) / 8)
			} else {
				Text(text!)
					.font(.muli(.bold, size: 12))
					.foregroundColor(.darkGray)
					.shrinks()
					.padding(.horizontal, 4)
			}
		}
	}
}

#if DEBUG
struct ReviewViewFooterPerformanceRatingButtonBadgeContent_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewFooterPerformanceRatingButtonBadgeContent(
			reviewData: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
				isNew: true
			),
			rating: .easy
		)
	}
}
#endif

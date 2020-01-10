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
				ActivityIndicator(radius: 1)
			} else {
				Text(text!)
					.font(.muli(.semiBold, size: 13))
					.foregroundColor(.darkGray)
					.lineLimit(1)
			}
		}
		.padding(.horizontal, 4)
		.padding(.vertical, 2)
	}
}

#if DEBUG
struct ReviewViewFooterPerformanceRatingButtonBadgeContent_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewFooterPerformanceRatingButtonBadgeContent(
			reviewData: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
			),
			rating: .easy
		)
	}
}
#endif

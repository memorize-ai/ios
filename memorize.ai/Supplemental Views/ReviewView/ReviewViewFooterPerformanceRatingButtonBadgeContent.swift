import SwiftUI

struct ReviewViewFooterPerformanceRatingButtonBadgeContent: View {
	@ObservedObject var reviewData: Card.ReviewData
	
	let rating: Card.PerformanceRating
	
	var dueDate: Date? {
		reviewData.predictionForRating(rating)
	}
	
	var body: some View {
		Group {
			if dueDate == nil {
				ActivityIndicator(radius: 1)
			} else {
				Text("+\(Date().compare(against: dueDate!).split(separator: " ").dropFirst().joined())")
					.font(.muli(.semiBold, size: 13))
					.foregroundColor(.darkGray)
					.lineLimit(1)
			}
		}
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

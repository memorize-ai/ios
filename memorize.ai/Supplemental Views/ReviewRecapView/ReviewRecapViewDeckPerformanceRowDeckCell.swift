import SwiftUI

struct ReviewRecapViewDeckPerformanceRowDeckCell: View {
	let deck: Deck
	let rating: Card.PerformanceRating
	let countOfRating: (Card.PerformanceRating) -> Int
	
	func ratingCountBadge(forRating rating: Card.PerformanceRating) -> some View {
		CustomRectangle(
			background: rating == self.rating
				? Color(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1)).opacity(0.1)
				: .lightGrayBackground
		) {
			Text("\(rating.title): \(countOfRating(rating).formatted)")
				.font(.muli(.bold, size: 14))
				.foregroundColor(.darkGray)
				.padding(.horizontal, 12)
				.padding(.vertical, 4)
		}
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: rating.badgeColor,
			borderWidth: 1,
			cornerRadius: 8
		) {
			VStack {
				// TODO: Add content
				HStack {
					ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
						self.ratingCountBadge(forRating: rating)
					}
				}
			}
			.padding(8)
		}
	}
}

#if DEBUG
struct ReviewRecapViewDeckPerformanceRowDeckCell_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewDeckPerformanceRowDeckCell(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			rating: .easy,
			countOfRating: { _ in 10 }
		)
	}
}
#endif

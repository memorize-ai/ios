import SwiftUI

struct ReviewRecapViewSectionPerformanceRowSectionCell: View {
	@ObservedObject var section: Deck.Section
	
	let rating: Card.PerformanceRating
	let hasNewCards: Bool
	let numberOfCards: Int
	let countOfRating: (Card.PerformanceRating) -> Int
	
	var cardCountMessage: String {
		"(\(numberOfCards.formatted) card\(numberOfCards == 1 ? "" : "s"))"
	}
	
	func ratingCountBadge(forRating rating: Card.PerformanceRating) -> some View {
		CustomRectangle(
			background: rating == self.rating
				? rating.badgeColor.opacity(0.1)
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
		ZStack(alignment: .topLeading) {
			CustomRectangle(
				background: Color.white,
				borderColor: rating.badgeColor,
				borderWidth: 1.5,
				cornerRadius: 8,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack {
					ReviewRecapViewSectionPerformanceRowSectionCellDeckName(
						deck: section.parent
					)
					.padding(.bottom, 8)
					HStack(alignment: .bottom) {
						Text(section.name)
							.font(.muli(.extraBold, size: 18))
							.foregroundColor(.darkGray)
							.shrinks(withLineLimit: 3)
							.layoutPriority(1)
						Text(cardCountMessage)
							.font(.muli(.bold, size: 13))
							.foregroundColor(.lightGrayText)
							.layoutPriority(1)
							.padding(.bottom, 2)
					}
					.padding(.bottom, 16)
					HStack {
						ForEach(
							[.easy, .struggled, .forgot] as [Card.PerformanceRating],
							id: \.self
						) { rating in
							self.ratingCountBadge(forRating: rating)
						}
					}
				}
				.padding(8)
				.frame(maxWidth: .infinity)
			}
			if hasNewCards {
				Circle()
					.foregroundColor(Color.darkBlue.opacity(0.5))
					.frame(width: 12, height: 12)
					.offset(x: -4, y: -4)
			}
		}
	}
}

#if DEBUG
struct ReviewRecapViewSectionPerformanceRowSectionCell_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewSectionPerformanceRowSectionCell(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0],
			rating: .easy,
			hasNewCards: true,
			numberOfCards: 20,
			countOfRating: { _ in 10 }
		)
	}
}
#endif

import SwiftUI

struct CramRecapViewSectionPerformanceRowSectionCell: View {
	@ObservedObject var section: Deck.Section
	
	let rating: Card.PerformanceRating
	
	let numberOfReviewedCardsForSection: (Deck.Section) -> Int
	
	var cardCountMessage: String {
		let count = numberOfReviewedCardsForSection(section)
		return "(\(count.formatted) card\(count == 1 ? "" : "s"))"
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: rating.badgeColor,
			borderWidth: 1,
			cornerRadius: 8
		) {
			HStack {
				Text(section.name)
					.font(.muli(.extraBold, size: 14))
					.foregroundColor(.darkGray)
				Text(cardCountMessage)
					.font(.muli(.semiBold, size: 14))
					.foregroundColor(.lightGrayText)
			}
			.padding(.horizontal)
			.padding(.vertical, 10)
			.frame(maxWidth: .infinity)
		}
	}
}

#if DEBUG
struct CramRecapViewSectionPerformanceRowSectionCell_Previews: PreviewProvider {
	static var previews: some View {
		CramRecapViewSectionPerformanceRowSectionCell(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0],
			rating: .easy,
			numberOfReviewedCardsForSection: { _ in 1 }
		)
	}
}
#endif

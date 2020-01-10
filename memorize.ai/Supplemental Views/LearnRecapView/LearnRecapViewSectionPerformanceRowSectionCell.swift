import SwiftUI

struct LearnRecapViewSectionPerformanceRowSectionCell: View {
	@EnvironmentObject var model: LearnViewModel
	
	@ObservedObject var section: Deck.Section
	
	let rating: Card.PerformanceRating
	
	var cardCountMessage: String {
		let count = model.numberOfReviewedCardsForSection(section)
		return "(\(count.formatted) card\(count == 1 ? "" : "s"))"
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: rating.badgeColor,
			borderWidth: 1
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
		}
	}
}

#if DEBUG
struct LearnRecapViewSectionPerformanceRowSectionCell_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewSectionPerformanceRowSectionCell(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0],
			rating: .easy
		)
		.environmentObject(LearnViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			section: nil
		))
	}
}
#endif

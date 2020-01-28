import SwiftUI

struct ReviewRecapViewSectionPerformanceSection: View {
	let frequentlyEasySections: [Deck.Section]
	let frequentlyStruggledSections: [Deck.Section]
	let frequentlyForgotSections: [Deck.Section]
	let countOfCardsForSection: (Deck.Section) -> Int
	let countOfRatingForSection: (Deck.Section, Card.PerformanceRating) -> Int
	let sectionHasNewCards: (Deck.Section) -> Bool
	
	var body: some View {
		VStack {
			CustomRectangle(
				background: Color.lightGrayBackground.opacity(0.5)
			) {
				Text("Section performance")
					.font(.muli(.extraBold, size: 23))
					.foregroundColor(.darkGray)
					.shrinks()
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
			}
			VStack(spacing: 12) {
				ReviewRecapViewSectionPerformanceRow(
					rating: .easy,
					sections: frequentlyEasySections,
					countOfCardsForSection: countOfCardsForSection,
					countOfRatingForSection: countOfRatingForSection,
					sectionHasNewCards: sectionHasNewCards
				)
				ReviewRecapViewSectionPerformanceRow(
					rating: .struggled,
					sections: frequentlyStruggledSections,
					countOfCardsForSection: countOfCardsForSection,
					countOfRatingForSection: countOfRatingForSection,
					sectionHasNewCards: sectionHasNewCards
				)
				ReviewRecapViewSectionPerformanceRow(
					rating: .forgot,
					sections: frequentlyForgotSections,
					countOfCardsForSection: countOfCardsForSection,
					countOfRatingForSection: countOfRatingForSection,
					sectionHasNewCards: sectionHasNewCards
				)
			}
		}
	}
}

#if DEBUG
struct ReviewRecapViewSectionPerformanceSection_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewSectionPerformanceSection(
			frequentlyEasySections: [],
			frequentlyStruggledSections: [],
			frequentlyForgotSections: [],
			countOfCardsForSection: { _ in 20 },
			countOfRatingForSection: { _, _ in 10 },
			sectionHasNewCards: { _ in true }
		)
	}
}
#endif

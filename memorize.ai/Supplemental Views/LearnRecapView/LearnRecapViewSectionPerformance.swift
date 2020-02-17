import SwiftUI

struct CramRecapViewSectionPerformance: View {
	let frequentlyEasySections: [Deck.Section]
	let frequentlyStruggledSections: [Deck.Section]
	let frequentlyForgotSections: [Deck.Section]
	let numberOfReviewedCardsForSection: (Deck.Section) -> Int
	
	var body: some View {
		VStack {
			Text("Section performance")
				.font(.muli(.extraBold, size: 23))
				.foregroundColor(.darkGray)
				.shrinks()
			VStack(spacing: 12) {
				CramRecapViewSectionPerformanceRow(
					rating: .easy,
					sections: frequentlyEasySections,
					numberOfReviewedCardsForSection: numberOfReviewedCardsForSection
				)
				CramRecapViewSectionPerformanceRow(
					rating: .struggled,
					sections: frequentlyStruggledSections,
					numberOfReviewedCardsForSection: numberOfReviewedCardsForSection
				)
				CramRecapViewSectionPerformanceRow(
					rating: .forgot,
					sections: frequentlyForgotSections,
					numberOfReviewedCardsForSection: numberOfReviewedCardsForSection
				)
			}
		}
	}
}

#if DEBUG
struct CramRecapViewSectionPerformance_Previews: PreviewProvider {
	static var previews: some View {
		CramRecapViewSectionPerformance(
			frequentlyEasySections: [],
			frequentlyStruggledSections: [],
			frequentlyForgotSections: [],
			numberOfReviewedCardsForSection: { _ in 1 }
		)
	}
}
#endif

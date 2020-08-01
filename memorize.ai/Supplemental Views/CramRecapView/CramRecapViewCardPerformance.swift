import SwiftUI

struct CramRecapViewCardPerformance: View {
	let frequentCardsForRating: (Card.PerformanceRating) -> [Card.CramData]
	let shouldShowSectionName: Bool
	
	var body: some View {
		VStack {
			Text("Card performance")
				.font(.muli(.extraBold, size: 23))
				.foregroundColor(.darkGray)
				.shrinks()
			VStack(spacing: 12) {
				ForEach(
					[.easy, .struggled, .forgot] as [Card.PerformanceRating],
					id: \.self
				) { rating in
					CramRecapViewCardPerformanceRow(
						rating: rating,
						frequentCardsForRating: self.frequentCardsForRating,
						shouldShowSectionName: self.shouldShowSectionName
					)
				}
			}
		}
	}
}

#if DEBUG
struct CramRecapViewCardPerformance_Previews: PreviewProvider {
	static var previews: some View {
		CramRecapViewCardPerformance(
			frequentCardsForRating: { _ in [] },
			shouldShowSectionName: true
		)
	}
}
#endif

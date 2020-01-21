import SwiftUI

struct LearnRecapViewCardPerformance: View {
	let frequentCardsForRating: (Card.PerformanceRating) -> [Card.LearnData]
	
	var body: some View {
		VStack {
			Text("Card performance")
				.font(.muli(.extraBold, size: 23))
				.foregroundColor(.darkGray)
				.shrinks()
			VStack(spacing: 12) {
				ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
					LearnRecapViewCardPerformanceRow(
						rating: rating,
						frequentCardsForRating: self.frequentCardsForRating
					)
				}
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewCardPerformance_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewCardPerformance(frequentCardsForRating: { _ in [] })
	}
}
#endif

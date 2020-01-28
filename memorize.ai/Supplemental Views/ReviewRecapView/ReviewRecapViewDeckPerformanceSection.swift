import SwiftUI

struct ReviewRecapViewDeckPerformanceSection: View {
	let frequentlyEasyDecks: [Deck]
	let frequentlyStruggledDecks: [Deck]
	let frequentlyForgotDecks: [Deck]
	let countOfRatingForDeck: (Deck, Card.PerformanceRating) -> Int
	
	var body: some View {
		VStack {
			Text("Deck performance")
				.font(.muli(.extraBold, size: 23))
				.foregroundColor(.darkGray)
				.shrinks()
			VStack(spacing: 12) {
				ReviewRecapViewDeckPerformanceRow(
					rating: .easy,
					decks: frequentlyEasyDecks,
					countOfRatingForDeck: countOfRatingForDeck
				)
				ReviewRecapViewDeckPerformanceRow(
					rating: .struggled,
					decks: frequentlyStruggledDecks,
					countOfRatingForDeck: countOfRatingForDeck
				)
				ReviewRecapViewDeckPerformanceRow(
					rating: .forgot,
					decks: frequentlyForgotDecks,
					countOfRatingForDeck: countOfRatingForDeck
				)
			}
		}
	}
}

#if DEBUG
struct ReviewRecapViewDeckPerformanceSection_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewDeckPerformanceSection(
			frequentlyEasyDecks: [],
			frequentlyStruggledDecks: [],
			frequentlyForgotDecks: [],
			countOfRatingForDeck: { _, _ in 10 }
		)
	}
}
#endif

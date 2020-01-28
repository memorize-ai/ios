import SwiftUI

struct ReviewRecapViewDeckPerformanceSection: View {
	let frequentlyEasyDecks: [Deck]
	let frequentlyStruggledDecks: [Deck]
	let frequentlyForgotDecks: [Deck]
	let countOfCardsForDeck: (Deck) -> Int
	let countOfRatingForDeck: (Deck, Card.PerformanceRating) -> Int
	
	var body: some View {
		VStack {
			CustomRectangle(
				background: Color.lightGrayBackground.opacity(0.5)
			) {
				Text("Deck performance")
					.font(.muli(.extraBold, size: 23))
					.foregroundColor(.darkGray)
					.shrinks()
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
			}
			VStack(spacing: 12) {
				ReviewRecapViewDeckPerformanceRow(
					rating: .easy,
					decks: frequentlyEasyDecks,
					countOfCardsForDeck: countOfCardsForDeck,
					countOfRatingForDeck: countOfRatingForDeck
				)
				ReviewRecapViewDeckPerformanceRow(
					rating: .struggled,
					decks: frequentlyStruggledDecks,
					countOfCardsForDeck: countOfCardsForDeck,
					countOfRatingForDeck: countOfRatingForDeck
				)
				ReviewRecapViewDeckPerformanceRow(
					rating: .forgot,
					decks: frequentlyForgotDecks,
					countOfCardsForDeck: countOfCardsForDeck,
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
			countOfCardsForDeck: { _ in 20 },
			countOfRatingForDeck: { _, _ in 10 }
		)
	}
}
#endif

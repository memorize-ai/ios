import SwiftUI

struct ReviewRecapViewDeckPerformanceSection: View {
	let frequentlyEasyDecks: [Deck]
	let frequentlyStruggledDecks: [Deck]
	let frequentlyForgotDecks: [Deck]
	
	var body: some View {
		VStack {
			Text("Deck performance")
				.font(.muli(.extraBold, size: 23))
				.foregroundColor(.darkGray)
				.shrinks()
			VStack(spacing: 12) {
				ReviewRecapViewDeckPerformanceRow(
					rating: .easy,
					decks: frequentlyEasyDecks
				)
				ReviewRecapViewDeckPerformanceRow(
					rating: .struggled,
					decks: frequentlyStruggledDecks
				)
				ReviewRecapViewDeckPerformanceRow(
					rating: .forgot,
					decks: frequentlyForgotDecks
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
			frequentlyForgotDecks: []
		)
	}
}
#endif

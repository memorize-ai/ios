import SwiftUI

struct ReviewRecapViewDeckPerformanceRow: View {
	let rating: Card.PerformanceRating
	let decks: [Deck]
	
	var body: some View {
		Text("ReviewRecapViewDeckPerformanceRow")
	}
}

#if DEBUG
struct ReviewRecapViewDeckPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewDeckPerformanceRow(rating: .easy, decks: [])
	}
}
#endif

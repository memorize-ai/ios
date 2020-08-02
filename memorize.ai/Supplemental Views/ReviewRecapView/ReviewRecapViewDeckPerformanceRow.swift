import SwiftUI

struct ReviewRecapViewDeckPerformanceRow: View {
	@State var isExpanded = false
	
	let rating: Card.PerformanceRating
	let decks: [Deck]
	let countOfCardsForDeck: (Deck) -> Int
	let countOfRatingForDeck: (Deck, Card.PerformanceRating) -> Int
	let deckHasNewCards: (Deck) -> Bool
	
	var deckCountMessage: String {
		let count = decks.count
		return "(\(count.formatted) deck\(count == 1 ? "" : "s"))"
	}
	
	var minusIcon: some View {
		Capsule()
			.foregroundColor(.darkBlue)
			.frame(height: 2)
	}
	
	var plusIcon: some View {
		ZStack {
			minusIcon
			minusIcon
				.rotationEffect(.degrees(90))
		}
	}
	
	var body: some View {
		LazyVStack(spacing: 12) {
			HStack {
				Text("Frequently \(rating.title.lowercased())")
					.font(.muli(.extraBold, size: 15))
					.foregroundColor(.darkGray)
					.layoutPriority(1)
				Rectangle()
					.foregroundColor(.lightGrayBorder)
					.frame(height: 1)
				Text(deckCountMessage)
					.font(.muli(.bold, size: 15))
					.foregroundColor(.darkBlue)
					.layoutPriority(1)
				Button(action: {
					self.isExpanded.toggle()
				}) {
					ZStack {
						Circle()
							.stroke(Color.lightGrayBorder)
						Group {
							if isExpanded {
								minusIcon
							} else {
								plusIcon
							}
						}
						.padding(5)
					}
					.frame(width: 21, height: 21)
				}
			}
			.padding(.horizontal, 23)
			if isExpanded && !decks.isEmpty {
				ForEach(decks) { deck in
					ReviewRecapViewDeckPerformanceRowDeckCell(
						deck: deck,
						rating: self.rating,
						hasNewCards: self.deckHasNewCards(deck),
						numberOfCards: self.countOfCardsForDeck(deck),
						countOfRating: {
							self.countOfRatingForDeck(deck, $0)
						}
					)
				}
				.padding(.horizontal, 23)
			}
		}
		.animation(.linear(duration: 0.15))
	}
}

#if DEBUG
struct ReviewRecapViewDeckPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewDeckPerformanceRow(
			rating: .easy,
			decks: [],
			countOfCardsForDeck: { _ in 20 },
			countOfRatingForDeck: { _, _ in 10 },
			deckHasNewCards: { _ in true }
		)
	}
}
#endif

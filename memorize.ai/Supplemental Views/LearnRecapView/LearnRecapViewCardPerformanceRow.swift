import SwiftUI

struct LearnRecapViewCardPerformanceRow: View {
	@State var isExpanded = false
	
	let rating: Card.PerformanceRating
	
	let frequentCardsForRating: (Card.PerformanceRating) -> [Card.LearnData]
	
	var cards: [Card.LearnData] {
		frequentCardsForRating(rating)
	}
	
	var cardCountMessage: String {
		let count = cards.count
		return "(\(count.formatted) card\(count == 1 ? "" : "s"))"
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
		VStack {
			HStack {
				Text("Frequently \(rating.title.lowercased())")
					.font(.muli(.extraBold, size: 15))
					.foregroundColor(.darkGray)
					.layoutPriority(1)
				Rectangle()
					.foregroundColor(.lightGrayBorder)
					.frame(height: 1)
				Text(cardCountMessage)
					.font(.muli(.bold, size: 15))
					.foregroundColor(.darkBlue)
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
			if isExpanded && !cards.isEmpty {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(cards) { card in
							LearnRecapViewCardPerformanceRowCardCell(
								card: card,
								rating: self.rating
							)
						}
					}
					.padding(.horizontal, 23)
					.padding(.vertical, 1)
				}
			}
		}
		.animation(.linear(duration: 0.15))
	}
}

#if DEBUG
struct LearnRecapViewCardPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewCardPerformanceRow(rating: .easy, frequentCardsForRating: { _ in [] })
	}
}
#endif

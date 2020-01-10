import SwiftUI

struct LearnRecapViewCardPerformanceRow: View {
	@EnvironmentObject var model: LearnViewModel
	
	let rating: Card.PerformanceRating
	
	var cards: [Card.LearnData] {
		model.frequentCards(forRating: rating)
	}
	
	var cardCountMessage: String {
		let count = cards.count
		return "(\(count.formatted) card\(count == 1 ? "" : "s"))"
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
			}
			.padding(.horizontal, 23)
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
}

#if DEBUG
struct LearnRecapViewCardPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewCardPerformanceRow(rating: .easy)
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif

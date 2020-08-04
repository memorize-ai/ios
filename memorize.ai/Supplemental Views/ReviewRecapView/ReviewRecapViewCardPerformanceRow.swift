import SwiftUI

struct ReviewRecapViewCardPerformanceRow: View {
	@State var isExpanded = false
	
	let rating: Card.PerformanceRating
	let cards: [Card.ReviewData]
	let shouldShowDeckName: Bool
	let shouldShowSectionName: Bool
	
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
	
	var content: some View {
		Group {
			HStack {
				Text(rating.title)
					.font(.muli(.extraBold, size: 15))
					.foregroundColor(.darkGray)
					.layoutPriority(1)
				Rectangle()
					.foregroundColor(.lightGrayBorder)
					.frame(height: 1)
				Text(cardCountMessage)
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
			if isExpanded && !cards.isEmpty {
				ForEach(cards) { card in
					ReviewRecapViewCardPerformanceRowCardCell(
						deck: card.parent.parent,
						section: card.parent.parent.section(withId: card.parent.sectionId)
							?? card.parent.parent.unsectionedSection,
						card: card.parent,
						reviewData: card,
						shouldShowDeckName: self.shouldShowDeckName,
						shouldShowSectionName: self.shouldShowSectionName
					)
				}
				.padding(.horizontal, 23)
			}
		}
	}
	
	var body: some View {
		TryLazyVStack(spacing: 12) { content }
			.animation(.linear(duration: 0.15))
	}
}

#if DEBUG
struct ReviewRecapViewCardPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewCardPerformanceRow(
			rating: .easy,
			cards: [],
			shouldShowDeckName: true,
			shouldShowSectionName: true
		)
	}
}
#endif

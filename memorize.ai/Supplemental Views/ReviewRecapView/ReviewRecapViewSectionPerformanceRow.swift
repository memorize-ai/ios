import SwiftUI

struct ReviewRecapViewSectionPerformanceRow: View {
	@State var isExpanded = false
	
	let rating: Card.PerformanceRating
	let sections: [Deck.Section]
	let countOfCardsForSection: (Deck.Section) -> Int
	let countOfRatingForSection: (Deck.Section, Card.PerformanceRating) -> Int
	let sectionHasNewCards: (Deck.Section) -> Bool
	
	var sectionCountMessage: String {
		let count = sections.count
		return "(\(count.formatted) section\(count == 1 ? "" : "s"))"
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
				Text("Frequently \(rating.title.lowercased())")
					.font(.muli(.extraBold, size: 15))
					.foregroundColor(.darkGray)
					.layoutPriority(1)
				Rectangle()
					.foregroundColor(.lightGrayBorder)
					.frame(height: 1)
				Text(sectionCountMessage)
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
			if isExpanded && !sections.isEmpty {
				ForEach(sections) { section in
					ReviewRecapViewSectionPerformanceRowSectionCell(
						section: section,
						rating: self.rating,
						hasNewCards: self.sectionHasNewCards(section),
						numberOfCards: self.countOfCardsForSection(section),
						countOfRating: {
							self.countOfRatingForSection(section, $0)
						}
					)
				}
				.padding(.horizontal, 23)
			}
		}
	}
	
	var body: some View {
		TryLazyVStack(spacing: 12) { self.content }
			.animation(.linear(duration: 0.15))
	}
}

#if DEBUG
struct ReviewRecapViewSectionPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewSectionPerformanceRow(
			rating: .easy,
			sections: [],
			countOfCardsForSection: { _ in 20 },
			countOfRatingForSection: { _, _ in 10 },
			sectionHasNewCards: { _ in true }
		)
	}
}
#endif

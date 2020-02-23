import SwiftUI

struct CramRecapViewSectionPerformanceRow: View {
	let rating: Card.PerformanceRating
	let sections: [Deck.Section]
	let numberOfReviewedCardsForSection: (Deck.Section) -> Int
	
	var sectionCountMessage: String {
		let count = sections.count
		return "(\(count.formatted) section\(count == 1 ? "" : "s"))"
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
				Text(sectionCountMessage)
					.font(.muli(.bold, size: 15))
					.foregroundColor(.darkBlue)
			}
			.padding(.horizontal, 23)
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(sections) { section in
						CramRecapViewSectionPerformanceRowSectionCell(
							section: section,
							rating: self.rating,
							numberOfReviewedCardsForSection: self.numberOfReviewedCardsForSection
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
struct CramRecapViewSectionPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		CramRecapViewSectionPerformanceRow(
			rating: .easy,
			sections: [],
			numberOfReviewedCardsForSection: { _ in 1 }
		)
	}
}
#endif

import SwiftUI

struct LearnRecapViewSectionPerformanceRow: View {
	@EnvironmentObject var model: LearnViewModel
	
	let rating: Card.PerformanceRating
	
	var sections: [Deck.Section] {
		model.frequentSections(forRating: rating)
	}
	
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
						LearnRecapViewSectionPerformanceRowSectionCell(
							section: section,
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
struct LearnRecapViewSectionPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewSectionPerformanceRow(rating: .easy)
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif

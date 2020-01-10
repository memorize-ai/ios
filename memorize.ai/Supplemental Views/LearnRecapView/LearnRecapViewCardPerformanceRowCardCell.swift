import SwiftUI

struct LearnRecapViewCardPerformanceRowCardCell: View {
	let card: Card.LearnData
	let rating: Card.PerformanceRating
	
	var body: some View {
		Text("Hello, World!")
	}
}

#if DEBUG
struct LearnRecapViewCardPerformanceRowCardCell_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewCardPerformanceRowCardCell(
			card: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
			),
			rating: .easy
		)
	}
}
#endif

import SwiftUI

struct LearnViewCardSection: View {
	@EnvironmentObject var model: LearnViewModel
	
	@ObservedObject var deck: Deck
	
	var body: some View {
		VStack(spacing: 8) {
			HStack {
				Text("\(deck.name)")
					.font(.muli(.bold, size: 17))
					.foregroundColor(.white)
					.align(to: .leading)
					.padding(.horizontal, 10)
				// TODO: Add section name
			}
			GeometryReader { geometry in
				ZStack(alignment: .bottom) {
					BlankReviewViewCard(
						geometry: geometry,
						scale: 0.9,
						offset: 16
					)
					BlankReviewViewCard(
						geometry: geometry,
						scale: 0.95,
						offset: 8
					)
					ReviewViewCard(geometry: geometry) {
						Text("Content")
					}
				}
			}
		}
	}
}

#if DEBUG
struct LearnViewCardSection_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewCardSection(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
		.environmentObject(LearnViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			section: nil
		))
	}
}
#endif

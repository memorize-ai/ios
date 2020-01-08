import SwiftUI

struct LearnViewCardSection: View {
	@EnvironmentObject var model: LearnViewModel
	
	@ObservedObject var deck: Deck
	
	var sectionName: String? {
		model.section?.name
	}
	
	var body: some View {
		VStack(spacing: 8) {
			HStack {
				Text("\(deck.name)")
					.foregroundColor(.white)
				if sectionName != nil {
					Group {
						Text("|")
							.foregroundColor(Color.white.opacity(0.5))
						Text(sectionName!)
							.foregroundColor(.white)
					}
				}
				Spacer()
			}
			.font(.muli(.bold, size: 17))
			.padding(.horizontal, 10)
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
						Group {
							if self.model.currentCard == nil {
								ActivityIndicator(color: .gray)
							} else {
								LearnViewCardContent(
									card: self.model.currentCard!
								)
							}
						}
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

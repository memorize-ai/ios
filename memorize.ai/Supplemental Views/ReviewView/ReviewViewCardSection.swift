import SwiftUI

struct ReviewViewCardSection: View {
	@EnvironmentObject var model: ReviewViewModel
	
	var section: Deck.Section? {
		model.section ?? model.currentSection
	}
	
	var body: some View {
		VStack(spacing: 8) {
			HStack {
				model.deck.map(ReviewViewCardSectionDeckName.init)
				section.map { section in
					LearnViewCardSectionSectionName(
						section: section
					)
				}
				Spacer()
				model.current.map(ReviewViewCardSectionIsNewLabel.init)
			}
			.font(.muli(.bold, size: 17))
			.padding(.horizontal, 10)
			GeometryReader { geometry in
				ZStack(alignment: .bottom) {
					Group {
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
					}
					.blur(radius: self.model.cardOffset.isZero ? 0 : 5)
					ReviewViewCard(geometry: geometry) {
						Group {
							if self.model.currentCard == nil {
								ActivityIndicator(color: .gray)
							} else {
								ReviewViewCardContent(
									card: self.model.currentCard!
								)
							}
						}
					}
					.offset(x: self.model.cardOffset)
				}
			}
		}
	}
}

#if DEBUG
struct ReviewViewCardSection_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewCardSection()
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif

import SwiftUI

struct ReviewViewCardSection: View {
	let deck: Deck?
	let section: Deck.Section?
	let currentSection: Deck.Section?
	let current: Card.ReviewData?
	let cardOffset: CGFloat
	let isWaitingForRating: Bool
	@Binding var currentSide: Card.Side
	
	var _section: Deck.Section? {
		section ?? currentSection
	}
	
	var body: some View {
		VStack(spacing: 8) {
			HStack {
				deck.map(ReviewViewCardSectionDeckName.init)
				_section.map { section in
					LearnViewCardSectionSectionName(
						section: section
					)
				}
				Spacer()
				current.map(ReviewViewCardSectionIsNewLabel.init)
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
					.blur(radius: self.cardOffset.isZero ? 0 : 5)
					ReviewViewCard(geometry: geometry) {
						Group {
							if self.current?.parent == nil {
								ActivityIndicator(color: .gray)
							} else {
								ReviewViewCardContent(
									currentSide: self.$currentSide,
									isWaitingForRating: self.isWaitingForRating,
									card: self.current!.parent
								)
							}
						}
					}
					.offset(x: self.cardOffset)
				}
			}
		}
	}
}

#if DEBUG
struct ReviewViewCardSection_Previews: PreviewProvider {
	static var previews: some View {
		Text("")
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif

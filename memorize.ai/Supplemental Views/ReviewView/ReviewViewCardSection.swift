import SwiftUI

struct ReviewViewCardSection: View {
	let deck: Deck?
	let currentDeck: Deck?
	let section: Deck.Section?
	let currentSection: Deck.Section?
	let current: Card.ReviewData?
	let cardOffset: CGFloat
	let isWaitingForRating: Bool
	
	@Binding var currentSide: Card.Side
	
	var _deck: Deck? {
		deck ?? currentDeck
	}
	
	var _section: Deck.Section? {
		section ?? currentSection
	}
	
	var body: some View {
		VStack(spacing: 8) {
			HStack {
				_deck.map(ReviewViewCardSectionDeckName.init)
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
							if self.current == nil {
								ActivityIndicator(color: .gray)
							} else {
								ReviewViewCardContent(
									isWaitingForRating: self.isWaitingForRating,
									card: self.current!.parent,
									currentSide: self.$currentSide
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
		ReviewViewCardSection(
			deck: nil,
			currentDeck: nil,
			section: nil,
			currentSection: nil,
			current: nil,
			cardOffset: 0,
			isWaitingForRating: true,
			currentSide: .constant(.front)
		)
	}
}
#endif

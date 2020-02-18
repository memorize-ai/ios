import SwiftUI
import LoadingState

struct CramViewCardSection: View {
	@ObservedObject var deck: Deck
	
	@Binding var currentSide: Card.Side
	
	let section: Deck.Section?
	let currentSection: Deck.Section?
	let cardOffset: CGFloat
	let currentCard: Card?
	let currentCardLoadingState: LoadingState
	let isWaitingForRating: Bool
	
	var _section: Deck.Section? {
		section ?? currentSection
	}
	
	var body: some View {
		VStack(spacing: 8) {
			HStack {
				Text(deck.name)
					.foregroundColor(.white)
					.shrinks()
				_section.map { section in
					CramViewCardSectionSectionName(
						section: section
					)
				}
				Spacer()
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
							if self.currentCard == nil || self.currentCardLoadingState.isLoading {
								ActivityIndicator(color: .gray)
							} else {
								CramViewCardContent(
									card: self.currentCard!,
									currentSide: self.$currentSide,
									isWaitingForRating: self.isWaitingForRating
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
struct CramViewCardSection_Previews: PreviewProvider {
	static var previews: some View {
		CramViewCardSection(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			currentSide: .constant(.front),
			section: nil,
			currentSection: nil,
			cardOffset: 0,
			currentCard: nil,
			currentCardLoadingState: .none,
			isWaitingForRating: true
		)
	}
}
#endif

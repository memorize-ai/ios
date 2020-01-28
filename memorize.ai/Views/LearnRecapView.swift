import SwiftUI

struct LearnRecapView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let deck: Deck
	let section: Deck.Section?
	let xpGained: Int
	let initialXP: Int
	let totalEasyRatingCount: Int
	let totalStruggledRatingCount: Int
	let totalForgotRatingCount: Int
	let frequentlyEasySections: [Deck.Section]
	let frequentlyStruggledSections: [Deck.Section]
	let frequentlyForgotSections: [Deck.Section]
	let frequentCardsForRating: (Card.PerformanceRating) -> [Card.LearnData]
	let numberOfReviewedCardsForSection: (Deck.Section) -> Int
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ZStack(alignment: .top) {
					Group {
						Color.lightGrayBackground
						HomeViewTopGradient(
							colors: [
								.init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1)),
								.init(#colorLiteral(red: 0.7529411765, green: 0.8862745098, blue: 0.2549019608, alpha: 1))
							],
							addedHeight: geometry.safeAreaInsets.top
						)
					}
					.edgesIgnoringSafeArea(.all)
					VStack {
						LearnRecapViewTopControls()
							.padding(.horizontal, 23)
						ScrollView {
							VStack(spacing: 30) {
								LearnRecapViewMainCard(
									user: self.currentStore.user,
									deck: self.deck,
									section: self.section,
									xpGained: self.xpGained,
									initialXP: self.initialXP,
									totalEasyRatingCount: self.totalEasyRatingCount,
									totalStruggledRatingCount: self.totalStruggledRatingCount,
									totalForgotRatingCount: self.totalForgotRatingCount
								)
								.padding(.horizontal, 8)
								if self.section == nil {
									LearnRecapViewSectionPerformance(
										frequentlyEasySections: self.frequentlyEasySections,
										frequentlyStruggledSections: self.frequentlyStruggledSections,
										frequentlyForgotSections: self.frequentlyForgotSections,
										numberOfReviewedCardsForSection: self.numberOfReviewedCardsForSection
									)
								}
								LearnRecapViewCardPerformance(
									frequentCardsForRating: self.frequentCardsForRating,
									shouldShowSectionName: self.section == nil
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
struct LearnRecapView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			LearnRecapView(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil,
				xpGained: 1,
				initialXP: 4,
				totalEasyRatingCount: 1,
				totalStruggledRatingCount: 3,
				totalForgotRatingCount: 4,
				frequentlyEasySections: [],
				frequentlyStruggledSections: [],
				frequentlyForgotSections: [],
				frequentCardsForRating: { _ in [] },
				numberOfReviewedCardsForSection: { _ in 1 }
			)
			LearnRecapView(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0],
				xpGained: 1,
				initialXP: 4,
				totalEasyRatingCount: 1,
				totalStruggledRatingCount: 3,
				totalForgotRatingCount: 4,
				frequentlyEasySections: [],
				frequentlyStruggledSections: [],
				frequentlyForgotSections: [],
				frequentCardsForRating: { _ in [] },
				numberOfReviewedCardsForSection: { _ in 1 }
			)
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

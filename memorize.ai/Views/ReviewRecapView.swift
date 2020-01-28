import SwiftUI

struct ReviewRecapView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let decks: [Deck]?
	let deck: Deck?
	let section: Deck.Section?
	let xpGained: Int
	let initialXP: Int
	let totalEasyRatingCount: Int
	let totalStruggledRatingCount: Int
	let totalForgotRatingCount: Int
	let numberOfNewlyMasteredCards: Int
	let numberOfNewCards: Int
	let frequentDecksForRating: (Card.PerformanceRating) -> [Deck]
	let countOfCardsForDeck: (Deck) -> Int
	let countOfRatingForDeck: (Deck, Card.PerformanceRating) -> Int
	let deckHasNewCards: (Deck) -> Bool
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				Group {
					Color.lightGrayBackground
					HomeViewTopGradient(
						addedHeight: geometry.safeAreaInsets.top
					)
				}
				.edgesIgnoringSafeArea(.all)
				VStack {
					LearnRecapViewTopControls()
						.padding(.horizontal, 23)
					ScrollView {
						VStack(spacing: 20) {
							ReviewRecapViewMainCard(
								user: self.currentStore.user,
								decks: self.decks,
								deck: self.deck,
								section: self.section,
								xpGained: self.xpGained,
								initialXP: self.initialXP,
								totalEasyRatingCount: self.totalEasyRatingCount,
								totalStruggledRatingCount: self.totalStruggledRatingCount,
								totalForgotRatingCount: self.totalForgotRatingCount
							)
							ReviewRecapViewThisSessionSection(
								numberOfNewlyMasteredCards: self.numberOfNewlyMasteredCards,
								numberOfNewCards: self.numberOfNewCards
							)
							if self.decks != nil {
								ReviewRecapViewDeckPerformanceSection(
									frequentlyEasyDecks: self.frequentDecksForRating(.easy),
									frequentlyStruggledDecks: self.frequentDecksForRating(.struggled),
									frequentlyForgotDecks: self.frequentDecksForRating(.forgot),
									countOfCardsForDeck: self.countOfCardsForDeck,
									countOfRatingForDeck: self.countOfRatingForDeck,
									deckHasNewCards: self.deckHasNewCards
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
struct ReviewRecapView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ReviewRecapView(
				decks: nil,
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil,
				xpGained: 0,
				initialXP: 0,
				totalEasyRatingCount: 4,
				totalStruggledRatingCount: 2,
				totalForgotRatingCount: 1,
				numberOfNewlyMasteredCards: 1,
				numberOfNewCards: 2,
				frequentDecksForRating: { _ in
					PREVIEW_CURRENT_STORE.user.decks
				},
				countOfCardsForDeck: { _ in 20 },
				countOfRatingForDeck: { _, _ in 10 },
				deckHasNewCards: { _ in true }
			)
			ReviewRecapView(
				decks: PREVIEW_CURRENT_STORE.user.decks,
				deck: nil,
				section: nil,
				xpGained: 0,
				initialXP: 0,
				totalEasyRatingCount: 4,
				totalStruggledRatingCount: 2,
				totalForgotRatingCount: 1,
				numberOfNewlyMasteredCards: 1,
				numberOfNewCards: 2,
				frequentDecksForRating: { _ in
					PREVIEW_CURRENT_STORE.user.decks
				},
				countOfCardsForDeck: { _ in 20 },
				countOfRatingForDeck: { _, _ in 10 },
				deckHasNewCards: { _ in true }
			)
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

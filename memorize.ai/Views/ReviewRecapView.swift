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
						VStack(spacing: 30) {
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
							.padding(.horizontal, 8)
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
				totalForgotRatingCount: 1
			)
			ReviewRecapView(
				decks: PREVIEW_CURRENT_STORE.user.decks,
				deck: nil,
				section: nil,
				xpGained: 0,
				initialXP: 0,
				totalEasyRatingCount: 4,
				totalStruggledRatingCount: 2,
				totalForgotRatingCount: 1
			)
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

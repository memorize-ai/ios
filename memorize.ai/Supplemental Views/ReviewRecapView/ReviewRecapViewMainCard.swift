import SwiftUI

struct ReviewRecapViewMainCard: View {
	@ObservedObject var user: User
	
	let decks: [Deck]?
	let deck: Deck?
	let section: Deck.Section?
	let xpGained: Int
	let initialXP: Int
	let totalEasyRatingCount: Int
	let totalStruggledRatingCount: Int
	let totalForgotRatingCount: Int
	
	var xpGainedMessage: String {
		"You gained \(xpGained == 0 ? "no xp" : "\(xpGained.formatted) xp!")"
	}
	
	var didReachNextLevel: Bool {
		user.level > User.levelForXP(initialXP)
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5
		) {
			VStack(spacing: 20) {
				CustomRectangle(background: Color.lightGrayBackground) {
					VStack {
						Text(xpGainedMessage)
							.font(.muli(.extraBold, size: 23))
							.foregroundColor(.darkGray)
							.shrinks(withLineLimit: 2)
						UserLevelView(user: user)
						if didReachNextLevel {
							HStack {
								Text("🎉")
								Text("You reached level \(user.level.formatted)!")
							}
							.font(.muli(.bold, size: 15))
							.foregroundColor(.darkGray)
							.padding(.top, 6)
						}
					}
					.padding()
					.frame(maxWidth: .infinity)
				}
				.padding([.horizontal, .top], 8)
				VStack(spacing: 2) {
					Text("Your performance ratings for")
						.font(.muli(.semiBold, size: 18))
						.foregroundColor(.lightGrayText)
						.shrinks()
					if decks == nil {
						Group {
							deck.map(ReviewRecapViewDeckName.init)
							section.map(LearnRecapViewMainCardSectionName.init)
						}
						.padding(.horizontal)
					} else {
						ScrollView(.horizontal, showsIndicators: false) {
							HStack {
								ForEach(
									decks!,
									content: ReviewRecapViewScrollableDeckName.init
								)
							}
							.padding(.horizontal, 8)
						}
						.padding(.top, 8)
					}
				}
				HorizontalBarGraph(
					rows: [
						.init(
							label: Card.PerformanceRating.easy.title.uppercased(),
							value: totalEasyRatingCount
						),
						.init(
							label: Card.PerformanceRating.struggled.title.uppercased(),
							value: totalStruggledRatingCount
						),
						.init(
							label: Card.PerformanceRating.forgot.title.uppercased(),
							value: totalForgotRatingCount
						)
					],
					color: .darkBlue
				)
				.padding([.horizontal, .bottom])
			}
		}
		.padding(.horizontal, 8)
	}
}

#if DEBUG
struct ReviewRecapViewMainCard_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewMainCard(
			user: PREVIEW_CURRENT_STORE.user,
			decks: nil,
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			section: nil,
			xpGained: 0,
			initialXP: 0,
			totalEasyRatingCount: 4,
			totalStruggledRatingCount: 2,
			totalForgotRatingCount: 1
		)
	}
}
#endif

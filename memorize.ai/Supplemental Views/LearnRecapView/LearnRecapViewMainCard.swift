import SwiftUI

struct LearnRecapViewMainCard: View {
	@ObservedObject var user: User
	@ObservedObject var deck: Deck
	
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
				CustomRectangle(
					background: Color.lightGrayBackground
				) {
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
					Text(deck.name)
						.font(.muli(.extraBold, size: 23))
						.foregroundColor(.darkGray)
						.shrinks(withLineLimit: 3)
				}
				.padding(.horizontal)
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
					color: .init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1))
				)
				.padding([.horizontal, .bottom])
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewMainCard_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewMainCard(
			user: PREVIEW_CURRENT_STORE.user,
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			xpGained: 1,
			initialXP: 3,
			totalEasyRatingCount: 2,
			totalStruggledRatingCount: 4,
			totalForgotRatingCount: 5
		)
	}
}
#endif

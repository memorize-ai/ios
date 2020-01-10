import SwiftUI

struct LearnRecapViewMainCard: View {
	@EnvironmentObject var model: LearnViewModel
	
	@ObservedObject var user: User
	@ObservedObject var deck: Deck
	
	var xpGainedMessage: String {
		"You gained \(model.xpGained == 0 ? "no xp" : "\(model.xpGained.formatted) xp!")"
	}
	
	var didReachNextLevel: Bool {
		user.level > User.levelForXP(model.initialXP)
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5
		) {
			VStack {
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
				Group {
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
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewMainCard_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewMainCard(
			user: PREVIEW_CURRENT_STORE.user,
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
		.environmentObject(LearnViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			section: nil
		))
	}
}
#endif

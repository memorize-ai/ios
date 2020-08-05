import SwiftUI

struct HomeViewReviewSection: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var user: User
	
	var dueCardsMessage: String {
		let dueCardCount = user.numberOfDueCards
		return "You have \(dueCardCount.nilIfZero?.formatted ?? "no") card\(dueCardCount == 1 ? "" : "s") due"
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white.opacity(0.8),
			borderColor: .lightGrayBorder,
			borderWidth: 1,
			shadowRadius: 5
		) {
			VStack {
				VStack {
					Text("Hello, \(user.name)")
						.font(.muli(.bold, size: 20))
						.alignment(.leading)
					Text(dueCardsMessage)
						.font(.muli(.bold, size: 15))
						.foregroundColor(.darkGray)
						.alignment(.leading)
						.padding(.top, 8)
						.padding(.bottom, 6)
					if user.numberOfDueCards > 0 {
						ReviewViewNavigationLink {
							CustomRectangle(
								background: {
									let count = self.user.numberOfDueCards
									if count < 10 { return .neonGreen }
									if count < 100 { return .neonOrange }
									return .neonRed
								}() as Color,
								cornerRadius: 14
							) {
								Text("REVIEW")
									.font(.muli(.bold, size: 12))
									.foregroundColor(.white)
									.frame(width: 92, height: 28)
							}
						}
						.alignment(.leading)
					}
				}
				.padding([.horizontal, .top])
				TryLazyVStack(spacing: 0) {
					ForEach(self.user.decks.filter { $0.userData?.isDue ?? false }) { deck in
						HomeViewReviewSectionDeckRow(deck: deck)
					}
				}
				.padding(.bottom, 8)
			}
		}
		.padding(.horizontal, 23)
		.padding(.bottom, 10)
	}
}

#if DEBUG
struct HomeViewReviewSection_Previews: PreviewProvider {
	static var previews: some View {
		return HomeViewReviewSection(
			user: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

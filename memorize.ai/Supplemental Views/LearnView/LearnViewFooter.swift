import SwiftUI

struct LearnViewFooter: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: LearnViewModel
	
	func ratingButton(
		forRating rating: Card.PerformanceRating,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5
			) {
				HStack {
					Text(rating.emoji)
					Text(rating.title.uppercased())
						.font(.muli(.bold, size: 14))
						.foregroundColor(.darkGray)
						.shrinks()
				}
				.padding(.horizontal)
				.frame(
					width: (SCREEN_SIZE.width - 8 * 4) / 3,
					height: 44
				)
			}
		}
	}
	
	var body: some View {
		ZStack {
			HStack {
				ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
					self.ratingButton(forRating: rating) {
						self.model.rateCurrentCard(
							withRating: rating,
							user: self.currentStore.user
						)
						playHaptic()
					}
				}
			}
			.offset(x: model.isWaitingForRating ? 0 : -SCREEN_SIZE.width)
			Text("Tap anywhere to continue")
				.font(.muli(.bold, size: 17))
				.foregroundColor(.darkGray)
				.offset(x: model.isWaitingForRating ? SCREEN_SIZE.width : 0)
		}
	}
}

#if DEBUG
struct LearnViewFooter_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewFooter()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif

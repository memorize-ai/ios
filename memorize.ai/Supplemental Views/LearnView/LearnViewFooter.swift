import SwiftUI
import Audio

struct LearnViewFooter: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let isWaitingForRating: Bool
	let rateCurrentCard: (Card.PerformanceRating, User) -> Void
	
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
						.foregroundColor(.darkGray)
						.shrinks()
				}
				.font(.muli(.extraBold, size: 14))
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
						self.rateCurrentCard(rating, self.currentStore.user)
						Audio.impact()
					}
				}
			}
			.offset(x: isWaitingForRating ? 0 : -SCREEN_SIZE.width)
			Text("Tap anywhere to continue")
				.font(.muli(.bold, size: 17))
				.foregroundColor(.darkGray)
				.offset(x: isWaitingForRating ? SCREEN_SIZE.width : 0)
		}
	}
}

#if DEBUG
struct LearnViewFooter_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewFooter(isWaitingForRating: true, rateCurrentCard: { _, _ in })
	}
}
#endif

import SwiftUI

struct LearnViewFooter: View {
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
					Text(rating.title)
				}
			}
		}
	}
	
	var body: some View {
		ZStack {
			HStack {
				ratingButton(forRating: .easy) {
					self.model.rateCurrentCard(withRating: .easy)
				}
				ratingButton(forRating: .struggled) {
					self.model.rateCurrentCard(withRating: .struggled)
				}
				ratingButton(forRating: .forgot) {
					self.model.rateCurrentCard(withRating: .forgot)
				}
			}
			.offset(y: model.isWaitingForRating ? 0 : 80)
			Text("Tap anywhere to continue")
				.font(.muli(.bold, size: 17))
				.foregroundColor(.darkGray)
		}
	}
}

#if DEBUG
struct LearnViewFooter_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewFooter()
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif

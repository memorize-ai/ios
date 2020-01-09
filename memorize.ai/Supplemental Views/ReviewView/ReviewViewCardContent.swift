import SwiftUI
import WebView

struct ReviewViewCardContent: View {
	@EnvironmentObject var model: ReviewViewModel
	
	@ObservedObject var card: Card
	
	@State var toggleIconDegrees = 0.0
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			WebView(
				html: card.renderSide(model.currentSide),
				baseURL: WEB_VIEW_BASE_URL
			)
			.cornerRadius(5)
			CardToggleButton(
				image: .greenSwapIcon,
				circleDimension: 40,
				fontSize: 13,
				side: $model.currentSide,
				degrees: $toggleIconDegrees
			)
			.padding([.trailing, .bottom], 10)
			.opacity(*model.isWaitingForRating)
		}
	}
}

#if DEBUG
struct ReviewViewCardContent_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewCardContent(
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
		)
		.environmentObject(ReviewViewModel(
			user: PREVIEW_CURRENT_STORE.user,
			deck: nil,
			section: nil
		))
	}
}
#endif

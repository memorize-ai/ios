import SwiftUI
import WebView

struct ReviewViewCardContent: View {
	@Binding var currentSide: Card.Side
	let isWaitingForRating: Bool
	
	@ObservedObject var card: Card
	
	@State var toggleIconDegrees = 0.0
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			WebView(
				html: card.renderSide(currentSide),
				baseURL: WEB_VIEW_BASE_URL
			)
			.cornerRadius(5)
			CardToggleButton(
				image: .greenSwapIcon,
				circleDimension: 40,
				fontSize: 13,
				side: $currentSide,
				degrees: $toggleIconDegrees
			)
			.padding([.trailing, .bottom], 10)
			.opacity(*isWaitingForRating)
		}
	}
}

#if DEBUG
struct ReviewViewCardContent_Previews: PreviewProvider {
	static var previews: some View {
		Text("")
		.environmentObject(ReviewViewModel(
			user: PREVIEW_CURRENT_STORE.user,
			deck: nil,
			section: nil
		))
	}
}
#endif

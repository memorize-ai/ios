import SwiftUI
import WebView

struct LearnViewCardContent: View {
	@ObservedObject var card: Card
	
	@State var toggleIconDegrees = 0.0
	
	@Binding var currentSide: Card.Side
	
	let isWaitingForRating: Bool
	
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
struct LearnViewCardContent_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewCardContent(
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
			currentSide: .constant(.front),
			isWaitingForRating: true
		)
	}
}
#endif

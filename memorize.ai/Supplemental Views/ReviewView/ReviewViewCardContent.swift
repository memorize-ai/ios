import SwiftUI
import WebView

struct ReviewViewCardContent: View {
	let isWaitingForRating: Bool
	
	@ObservedObject var card: Card
	
	@State var toggleIconDegrees = 0.0
	
	@Binding var currentSide: Card.Side
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			card.webView(forSide: currentSide)
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
		ReviewViewCardContent(
			isWaitingForRating: true,
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
			currentSide: .constant(.front)
		)
	}
}
#endif

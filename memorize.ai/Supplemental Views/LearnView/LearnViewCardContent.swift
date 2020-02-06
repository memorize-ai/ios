import SwiftUI
import WebView

struct LearnViewCardContent: View {
	@ObservedObject var card: Card
	
	@State var toggleIconDegrees = 0.0
	
	@Binding var currentSide: Card.Side
	
	let isWaitingForRating: Bool
	
	var body: some View {
		ZStack(alignment: .bottom) {
			card.webView(forSide: currentSide)
				.cornerRadius(5)
			HStack(spacing: 10) {
				Button(action: {
					self.card.playAudio(forSide: self.currentSide)
				}) {
					Image(systemName: .speaker3Fill)
						.foregroundColor(.darkBlue)
						.scaleEffect(1.35)
				}
				.opacity(*card.hasAudio(forSide: currentSide))
				.animation(.linear(duration: 0.15))
				.padding(.leading, 16)
				Spacer()
				CardToggleButton(
					image: .greenSwapIcon,
					circleDimension: 40,
					fontSize: 13,
					side: $currentSide,
					degrees: $toggleIconDegrees
				) {
					self.card.playAudio(forSide: $0)
				}
				.padding([.trailing, .bottom], 10)
				.opacity(*isWaitingForRating)
			}
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

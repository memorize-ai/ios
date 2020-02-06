import SwiftUI
import WebView
import HTML

struct CardPreviewCell: View {
	@ObservedObject var card: Card
	
	@State var side = Card.Side.front
	@State var toggleIconDegrees = 0.0
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5
		) {
			ZStack(alignment: .bottom) {
				card.webView(forSide: side)
					.cornerRadius(5)
				HStack {
					Button(action: {
						self.card.playAudio(forSide: self.side)
					}) {
						Image(systemName: .speaker3Fill)
							.foregroundColor(.darkBlue)
					}
					.opacity(*card.hasAudio(forSide: side))
					.animation(.linear(duration: 0.15))
					Spacer()
					CardToggleButton(
						side: $side,
						degrees: $toggleIconDegrees
					) {
						self.card.playAudio(forSide: $0)
					}
					.padding(.bottom, 10)
				}
				.padding(.horizontal, 10)
			}
		}
	}
}

#if DEBUG
struct CardPreviewCell_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.gray
				.edgesIgnoringSafeArea(.all)
			CardPreviewCell(
				card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[1]
			)
			.frame(width: 246, height: 354)
		}
	}
}
#endif

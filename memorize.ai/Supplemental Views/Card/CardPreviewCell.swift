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
			ZStack(alignment: .bottomTrailing) {
				WebView(
					html: card.renderSide(side),
					baseURL: WEB_VIEW_BASE_URL
				)
				.cornerRadius(5)
				CardToggleButton(
					side: $side,
					degrees: $toggleIconDegrees
				)
				.padding([.trailing, .bottom], 10)
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

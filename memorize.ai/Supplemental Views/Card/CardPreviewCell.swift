import SwiftUI
import WebView
import HTML

struct CardPreviewCell: View {
	@ObservedObject var card: Card
	
	@State var side = Card.Side.front
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5
		) {
			WebView(html: card.renderSide(side))
		}
	}
}

#if DEBUG
struct CardPreviewCell_Previews: PreviewProvider {
	static var previews: some View {
		CardPreviewCell(
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[1]
		)
		.frame(width: 246, height: 354)
	}
}
#endif

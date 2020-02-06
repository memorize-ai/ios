import SwiftUI
import WebView

struct DecksViewCardPreviewSheetView: View {
	@ObservedObject var card: Card
	
	@State var currentSide = Card.Side.front
	@State var toggleIconDegrees = 0.0
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .bottomTrailing) {
				self.card.webView(forSide: self.currentSide)
					.cornerRadius(5)
				CardToggleButton(
					circleDimension: 40,
					fontSize: 13,
					side: self.$currentSide,
					degrees: self.$toggleIconDegrees
				)
				.padding([.trailing, .bottom], max(geometry.safeAreaInsets.bottom, 10))
			}
		}
		.edgesIgnoringSafeArea(.all)
	}
}

#if DEBUG
struct DecksViewCardPreviewSheetView_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewCardPreviewSheetView(
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
		)
	}
}
#endif

import SwiftUI
import WebView

struct DecksViewCardPreviewSheetView: View {
	@ObservedObject var card: Card
	
	@State var currentSide = Card.Side.front
	@State var toggleIconDegrees = 0.0
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .bottom) {
				self.card.webView(forSide: self.currentSide)
					.cornerRadius(5)
				HStack {
					Button(action: {
						self.card.playAudio(forSide: self.currentSide)
					}) {
						Image(systemName: .speaker3Fill)
							.foregroundColor(.darkBlue)
							.scaleEffect(1.35)
					}
					.opacity(*self.card.hasAudio(forSide: self.currentSide))
					.animation(.linear(duration: 0.15))
					Spacer()
					CardToggleButton(
						circleDimension: 40,
						fontSize: 13,
						side: self.$currentSide,
						degrees: self.$toggleIconDegrees
					) {
						self.card.playAudio(forSide: $0)
					}
				}
				.padding([.horizontal, .bottom], max(geometry.safeAreaInsets.bottom, 10))
			}
		}
		.edgesIgnoringSafeArea(.all)
		.onAppear {
			self.card.playAudio(forSide: .front)
		}
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

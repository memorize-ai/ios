import SwiftUI
import WebView
import HTML

struct CardPreviewCell: View {
	@ObservedObject var card: Card
	
	@State var side = Card.Side.front
	@State var degrees = 0.0
	
	var toggleIcon: some View {
		ZStack {
			Circle()
				.foregroundColor(.lightGray)
			Image.swapIcon
				.resizable()
				.renderingMode(.original)
				.aspectRatio(contentMode: .fit)
				.padding(6)
				.rotationEffect(.degrees(degrees))
		}
		.padding([.trailing, .bottom], 10)
		.frame(width: 40, height: 40)
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5
		) {
			ZStack(alignment: .bottomTrailing) {
				WebView(html: card.renderSide(side))
				HStack {
					Text(side == .front ? "FRONT" : "BACK")
						.font(.muli(.bold, size: 10))
						.foregroundColor(Color.gray.opacity(0.7))
					Button(action: {
						self.side.toggle()
						withAnimation {
							self.degrees += 180
						}
					}) {
						toggleIcon
					}
				}
			}
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

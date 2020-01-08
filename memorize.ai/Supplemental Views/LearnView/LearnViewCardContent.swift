import SwiftUI

struct LearnViewCardContent: View {
	@ObservedObject var card: Card
	
	@State var side = Card.Side.front
	@State var toggleIconDegrees = 0.0
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			Text(card.front)
			CardToggleButton(
				image: .greenSwapIcon,
				side: $side,
				degrees: $toggleIconDegrees
			)
			.padding([.trailing, .bottom], 10)
		}
	}
}

#if DEBUG
struct LearnViewCardContent_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewCardContent(
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
		)
	}
}
#endif

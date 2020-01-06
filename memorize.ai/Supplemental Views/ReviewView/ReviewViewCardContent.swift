import SwiftUI

struct ReviewViewCardContent: View {
	@State var side = Card.Side.front
	@State var toggleIconDegrees = 0.0
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			Text("Content")
			CardToggleButton(
				side: $side,
				degrees: $toggleIconDegrees
			)
			.padding([.trailing, .bottom], 10)
		}
	}
}

#if DEBUG
struct ReviewViewCardContent_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewCardContent()
	}
}
#endif

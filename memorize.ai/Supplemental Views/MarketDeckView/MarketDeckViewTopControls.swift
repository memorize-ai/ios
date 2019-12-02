import SwiftUI

struct MarketDeckViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		HStack {
			Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				LeftArrowHead(height: 20)
			}
			Spacer()
			Button(action: {
				// TODO: Share deck
			}) {
				Image(systemName: .squareAndArrowUp)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.foregroundColor(Color.white.opacity(0.8))
					.frame(width: 23, height: 23)
			}
		}
	}
}

#if DEBUG
struct MarketDeckViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewTopControls()
	}
}
#endif

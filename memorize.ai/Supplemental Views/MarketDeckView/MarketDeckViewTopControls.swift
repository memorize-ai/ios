import SwiftUI

struct MarketDeckViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var deck: Deck
	
	var body: some View {
		HStack {
			Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				LeftArrowHead(height: 20)
			}
			Spacer()
			Button(action: {
				guard let url = self.deck.getUrl else {
					return showAlert(
						title: "An unknown error occurred",
						message: "Please try again"
					)
				}
				
				share(url)
			}) {
				Group {
					if deck.creatorLoadingState.isLoading {
						ActivityIndicator()
					} else {
						Image(systemName: .squareAndArrowUp)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.foregroundColor(Color.white.opacity(0.8))
					}
				}
				.frame(width: 23, height: 23)
			}
			.disabled(!deck.creatorLoadingState.didSucceed)
		}
	}
}

#if DEBUG
struct MarketDeckViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewTopControls()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

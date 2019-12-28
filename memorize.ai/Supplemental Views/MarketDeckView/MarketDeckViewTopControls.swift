import SwiftUI

struct MarketDeckViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var deck: Deck
	
	let shareView = ShareView()
	
	var body: some View {
		HStack {
			Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				LeftArrowHead(height: 20)
			}
			Spacer()
			Button(action: {
				self.shareView.share(items: [
					"""
					Check out \(self.deck.name) by \(self.deck.creator?.name ?? "(unknown)") on memorize.ai
					
					Download on the App Store: \(APP_STORE_URL)
					Learn more at \(WEB_URL)
					"""
				])
			}) {
				ZStack {
					if deck.creatorLoadingState.isLoading {
						ActivityIndicator()
					} else {
						Image(systemName: .squareAndArrowUp)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.foregroundColor(Color.white.opacity(0.8))
							.frame(width: 23, height: 23)
					}
					shareView
				}
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

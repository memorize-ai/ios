import SwiftUI

struct MarketDeckViewInfoPanels: View {
	@EnvironmentObject var deck: Deck
	
	var divider: some View {
		Rectangle()
			.foregroundColor(literal: #colorLiteral(red: 0.8078431373, green: 0.8078431373, blue: 0.8078431373, alpha: 0.5))
			.frame(width: 1, height: 28)
	}
	
	var ratingPanel: some View {
		EmptyView() // TODO: Add content
	}
	
	func textPanel(content: String, description: String) -> some View {
		EmptyView() // TODO: Add content
	}
	
	var body: some View {
		HStack {
			ratingPanel
			divider
			textPanel(
				content: deck.numberOfDownloads.formatted,
				description: "Download\(deck.numberOfDownloads == 1 ? "" : "s")"
			)
			divider
			textPanel(
				content: deck.numberOfCards.formatted,
				description: "Card\(deck.numberOfCards == 1 ? "" : "s")"
			)
		}
		.frame(height: 30)
	}
}

#if DEBUG
struct MarketDeckViewInfoPanels_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewInfoPanels()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

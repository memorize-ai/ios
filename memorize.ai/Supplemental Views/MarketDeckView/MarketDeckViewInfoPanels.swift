import SwiftUI

struct MarketDeckViewInfoPanels: View {
	@EnvironmentObject var deck: Deck
	
	var averageRating: String {
		.init(deck.averageRating.oneDecimalPlace)
	}
	
	var numberOfRatings: String {
		"\(deck.numberOfRatings.formatted) Rating\(deck.numberOfRatings == 1 ? "" : "s")"
	}
	
	var divider: some View {
		Group {
			Spacer()
			Rectangle()
				.foregroundColor(literal: #colorLiteral(red: 0.8078431373, green: 0.8078431373, blue: 0.8078431373, alpha: 0.5))
				.frame(width: 1.5, height: 28)
			Spacer()
		}
	}
	
	var ratingPanel: some View {
		VStack(alignment: .leading) {
			HStack {
				// TODO: Add stars
				Text(averageRating)
					.font(.muli(.extraBold, size: 19))
					.foregroundColor(Color.white.opacity(0.7))
			}
			Text(numberOfRatings)
				.font(.muli(.bold, size: 12))
				.foregroundColor(.white)
		}
	}
	
	func textPanel(content: String, description: String) -> some View {
		VStack {
			Text(content)
			Text(description)
		}
		.font(.muli(.bold, size: 17))
		.foregroundColor(.white)
	}
	
	var body: some View {
		HStack {
			Spacer()
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
			Spacer()
		}
		.padding(.horizontal, 23)
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

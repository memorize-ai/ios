import SwiftUI

struct DeckCell<Content: View>: View {
	@ObservedObject var deck: Deck
	
	let width: CGFloat
	let content: Content
	
	init(deck: Deck, width: CGFloat, content: () -> Content) {
		self.deck = deck
		self.width = width
		self.content = content()
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5,
			cornerRadius: 8
		) {
			VStack {
				Image("GeometryPrepDeck")
					.resizable()
					.renderingMode(.original)
					.aspectRatio(contentMode: .fill)
					.frame(height: width * 111 / 165)
				VStack(alignment: .leading) {
					Text(deck.name)
						.font(.muli(.bold, size: 13.5))
						.foregroundColor(.darkGray)
					Text(deck.subtitle)
						.font(.muli(.regular, size: 11))
						.foregroundColor(.lightGrayText)
						.padding(.top, 4)
					HStack {
						DeckStars(stars: deck.averageRating)
						Text(deck.numberOfRatings.formatted)
							.font(.muli(.regular, size: 11))
							.foregroundColor(.lightGrayText)
							.padding(.leading, -3)
					}
					HStack {
						Image.grayDownloadIcon
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fit)
							.frame(width: 10)
						Text(deck.numberOfDownloads.formatted)
							.font(.muli(.regular, size: 11))
							.foregroundColor(.lightGrayText)
							.padding(.leading, -1)
					}
				}
				.padding(.horizontal, 8)
				.padding(.top, 4)
				.padding(.bottom, 16)
				content
			}
			.frame(width: width)
		}
	}
}

#if DEBUG
struct DeckCell_Previews: PreviewProvider {
	static var previews: some View {
		DeckCell(deck: .init(
			id: "0",
			name: "Geometry Prep",
			subtitle: "Angles, lines, triangles and other polygons",
			numberOfViews: 1000000000,
			numberOfUniqueViews: 200000,
			numberOfRatings: 12400,
			averageRating: 4.5,
			numberOfDownloads: 196400
		), width: 165) { EmptyView() }
	}
}
#endif

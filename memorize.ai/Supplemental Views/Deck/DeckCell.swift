import SwiftUI

struct DeckCell: View {
	@ObservedObject var deck: Deck
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5
		) {
			VStack {
				Image("GeometryPrepDeck")
					.resizable()
					.renderingMode(.original)
					.aspectRatio(contentMode: .fit)
					.frame(height: 111)
				Group {
					Text(deck.name)
						.font(.muli(.bold, size: 13.5))
						.foregroundColor(.darkGray)
						.padding(.top, 4)
					Text(deck.subtitle)
						.font(.muli(.regular, size: 11))
						.foregroundColor(.lightGrayText)
						.padding(.top, 4)
					HStack {
						Image.grayDownloadIcon
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fit)
							.frame(width: 10)
						Text(deck.numberOfDownloads.formatted)
							.font(.muli(.regular, size: 11))
							.foregroundColor(.lightGrayText)
					}
				}
				.align(to: .leading)
				.padding(.horizontal, 8)
			}
			.cornerRadius(8)
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
		))
		.frame(width: 165)
	}
}
#endif

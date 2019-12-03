import SwiftUI

struct EmptyDeckCell: View {
	let deck: Deck
	let width: CGFloat
	
	var body: some View {
		DeckCell(
			deck: deck,
			width: width
		) {
			Rectangle()
				.frame(width: 0, height: 0)
				.padding(.top, 6)
		}
	}
}

#if DEBUG
struct EmptyDeckCell_Previews: PreviewProvider {
	static var previews: some View {
		EmptyDeckCell(
			deck: .init(
				id: "0",
				topics: [],
				hasImage: true,
				image: .init("GeometryPrepDeck"),
				name: "Geometry Prep",
				subtitle: "Angles, lines, triangles and other polygons",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				averageRating: 4.5,
				numberOfDownloads: 196400,
				numberOfCards: 19640,
				creatorId: "0",
				dateCreated: .now,
				dateLastUpdated: .now
			),
			width: 165
		)
	}
}
#endif

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
					.scaledToFit()
				Text(deck.name)
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
			name: "GeometryPrep",
			subtitle: "Angles, lines, triangles and other polygons",
			numberOfViews: 1000,
			numberOfUniqueViews: 200,
			numberOfRatings: 124,
			averageRating: 4.5,
			numberOfDownloads: 196
		))
		.frame(width: 165)
	}
}
#endif

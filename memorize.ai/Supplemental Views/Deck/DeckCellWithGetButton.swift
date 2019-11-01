import SwiftUI

struct DeckCellWithGetButton: View {
	let deck: Deck
	let width: CGFloat
	let isLoading: Bool
	let onGetClick: () -> Void
	
	var body: some View {
		DeckCell(deck: deck, width: width) {
			Button(action: onGetClick) {
				CustomRectangle(
					background: Color.darkBlue,
					cornerRadius: 8
				) {
					Group {
						if isLoading {
							Text("GET")
								.font(.muli(.bold, size: 12))
						} else {
							ActivityIndicator(radius: 8)
						}
					}
					.foregroundColor(.white)
					.frame(height: 33)
					.frame(maxWidth: .infinity)
				}
				.padding([.horizontal, .bottom], 18)
				.padding(.top, 10)
			}
			.disabled(isLoading)
		}
	}
}

#if DEBUG
struct DeckCellWithGetButton_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			DeckCellWithGetButton(
				deck: .init(
					id: "0",
					hasImage: true,
					image: .init("GeometryPrepDeck"),
					name: "Geometry Prep",
					subtitle: "Angles, lines, triangles and other polygons",
					numberOfViews: 1000000000,
					numberOfUniqueViews: 200000,
					numberOfRatings: 12400,
					averageRating: 4.5,
					numberOfDownloads: 196400,
					dateCreated: .init(),
					dateLastUpdated: .init()
				),
				width: 165,
				isLoading: false
			) {}
			DeckCellWithGetButton(
				deck: .init(
					id: "0",
					hasImage: true,
					image: .init("GeometryPrepDeck"),
					name: "Geometry Prep",
					subtitle: "Angles, lines, triangles and other polygons",
					numberOfViews: 1000000000,
					numberOfUniqueViews: 200000,
					numberOfRatings: 12400,
					averageRating: 4.5,
					numberOfDownloads: 196400,
					dateCreated: .init(),
					dateLastUpdated: .init()
				),
				width: 165,
				isLoading: true
			) {}
		}
	}
}
#endif

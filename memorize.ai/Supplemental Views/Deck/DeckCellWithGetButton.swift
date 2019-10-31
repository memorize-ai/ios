import SwiftUI

struct DeckCellWithGetButton: View {
	let deck: Deck
	let width: CGFloat
	let onGetClick: () -> Void
	
	var body: some View {
		DeckCell(
			deck: deck,
			width: width
		) {
			Button(action: onGetClick) {
				CustomRectangle(
					background: Color.darkBlue,
					cornerRadius: 8
				) {
					Text("GET")
						.font(.muli(.bold, size: 12))
						.foregroundColor(.white)
						.frame(height: 33)
						.frame(maxWidth: .infinity)
				}
				.padding([.horizontal, .bottom], 18)
				.padding(.top, 10)
			}
		}
	}
}

#if DEBUG
struct DeckCellWithGetButton_Previews: PreviewProvider {
	static var previews: some View {
		DeckCellWithGetButton(
			deck: .init(
				id: "0",
				name: "Geometry Prep",
				subtitle: "Angles, lines, triangles and other polygons",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				averageRating: 4.5,
				numberOfDownloads: 196400
			),
			width: 165
		) {}
	}
}
#endif

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
							ActivityIndicator(radius: 8)
						} else {
							Text("GET")
								.font(.muli(.bold, size: 12))
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
					topics: [],
					hasImage: true,
					image: .init("GeometryPrepDeck"),
					name: "Basic Web Development",
					subtitle: "Mostly just HTML",
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
					topics: [],
					hasImage: true,
					image: .init("GeometryPrepDeck"),
					name: "Web Development with CSS",
					subtitle: "Animations, layouting, HTML, and much more",
					numberOfViews: 1000000000,
					numberOfUniqueViews: 200000,
					numberOfRatings: 250,
					averageRating: 4.5,
					numberOfDownloads: 400,
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

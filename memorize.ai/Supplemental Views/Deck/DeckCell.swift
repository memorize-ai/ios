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
			borderWidth: deck.hasImage ? 0 : 1.5,
			cornerRadius: 8
		) {
			VStack {
				Group {
					if deck.imageLoadingState.didFail {
						ZStack {
							Color.lightGrayBackground
							Image(systemName: .exclamationmarkTriangle)
								.foregroundColor(.gray)
								.scaleEffect(1.5)
						}
					} else if deck.hasImage {
						if deck.image == nil {
							ZStack {
								Color.lightGrayBackground
								ActivityIndicator(color: .gray)
							}
						} else {
							deck.displayImage?
								.resizable()
								.renderingMode(.original)
								.aspectRatio(contentMode: .fill)
						}
					} else {
						ZStack {
							Color.lightGrayBackground
							Image(systemName: .questionmark)
								.foregroundColor(.gray)
								.scaleEffect(1.5)
						}
					}
				}
				.cornerRadius(8, corners: [.topLeft, .topRight])
				.frame(height: width * 111 / 165)
				VStack(alignment: .leading) {
					Text(deck.name)
						.font(.muli(.bold, size: 13.5))
						.foregroundColor(.darkGray)
					Text(deck.subtitle)
						.font(.muli(.regular, size: 11))
						.foregroundColor(.lightGrayText)
						.lineLimit(3)
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
				.alignment(.leading)
				.padding(.horizontal, 8)
				.padding(.top, 4)
				content
			}
			.frame(width: width)
		}
		.onAppear {
			self.deck.loadImage()
		}
	}
}

#if DEBUG
struct DeckCell_Previews: PreviewProvider {
	static var previews: some View {
		let failedDeck = Deck._new(
			id: "0",
			topics: [],
			hasImage: true,
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
		)
		failedDeck.imageLoadingState.fail(message: "Self-invoked")
		return ZStack {
			Color.gray
				.edgesIgnoringSafeArea(.all)
			Grid(
				elements: [
					DeckCell(
						deck: ._new(
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
						width: 165,
						content: EmptyView.init
					),
					DeckCell(
						deck: ._new(
							id: "0",
							topics: [],
							hasImage: true,
							name: "Geometry Prep",
							subtitle: "Text here",
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
						width: 165,
						content: EmptyView.init
					),
					DeckCell(
						deck: ._new(
							id: "0",
							topics: [],
							hasImage: false,
							name: "Geometry Prep",
							subtitle: "Angles, lines, triangles and other polygons. Angles, lines, triangles and other polygons.",
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
						width: 165,
						content: EmptyView.init
					),
					DeckCell(
						deck: failedDeck,
						width: 165,
						content: EmptyView.init
					)
				],
				columns: 2,
				horizontalSpacing: 20,
				verticalSpacing: 20
			)
		}
	}
}
#endif

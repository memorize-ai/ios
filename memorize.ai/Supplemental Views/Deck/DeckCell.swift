import SwiftUI

struct DeckCell<Content: View>: View {
	@ObservedObject var deck: Deck
	
	let width: CGFloat
	let imageHeight: CGFloat
	let titleFontSize: CGFloat
	let content: Content
	
	init(deck: Deck, width: CGFloat, imageHeight: CGFloat? = nil, titleFontSize: CGFloat = 13.5, content: () -> Content) {
		self.deck = deck
		self.width = width
		self.imageHeight = imageHeight ?? width * 111 / 165
		self.titleFontSize = titleFontSize
		self.content = content()
	}
	
	var imageDimension: CGFloat {
		min(width - 40, 200)
	}
	
	var isInfoHorizontal: Bool {
		width >= 290
	}
	
	var infoDivider: some View {
		isInfoHorizontal
			? Divider()
			: nil
	}
	
	var info: some View {
		Group {
			HStack(spacing: 6) {
				DeckStars(stars: deck.averageRating, dimension: 20)
				Text(deck.numberOfRatings.formatted)
					.fixedSize()
					.font(.muli(.semiBold, size: 15))
					.foregroundColor(.lightGrayText)
			}
			infoDivider
			HStack {
				Image.grayDownloadIcon
					.resizable()
					.renderingMode(.original)
					.aspectRatio(contentMode: .fit)
					.frame(width: 15)
				Text(deck.numberOfDownloads.formatted)
					.font(.muli(.semiBold, size: 15))
					.foregroundColor(.lightGrayText)
					.padding(.leading, -1)
			}
			infoDivider
			HStack {
				Image.users
					.resizable()
					.renderingMode(.original)
					.aspectRatio(contentMode: .fit)
					.frame(width: 18)
				Text(deck.numberOfCurrentUsers.formatted)
					.font(.muli(.semiBold, size: 15))
					.foregroundColor(.lightGrayText)
					.padding(.leading, -1)
			}
		}
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			cornerRadius: 8,
			shadowRadius: 5
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
						if deck.displayImage == nil {
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
						Deck.DEFAULT_IMAGE
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fill)
					}
				}
				.frame(width: imageDimension, height: imageDimension)
				.cornerRadius(8)
				.clipped()
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color(hexadecimal6: 0xEEEEEE))
				)
				.padding(.top, 12)
				VStack(alignment: .leading) {
					Text(deck.name)
						.font(.muli(.bold, size: titleFontSize))
						.foregroundColor(.darkGray)
					Text(deck.subtitle)
						.font(.muli(.regular, size: 11))
						.foregroundColor(.lightGrayText)
						.lineLimit(3)
						.padding(.top, 4)
					if isInfoHorizontal {
						HStack(spacing: 16) {
							info
						}
					} else {
						VStack(alignment: .leading) {
							info
						}
					}
				}
				.alignment(.leading)
				.padding(.horizontal, 18)
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
			ScrollView {
				VStack {
					ForEach([
						Deck._new(
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
						Deck._new(
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
						Deck._new(
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
						failedDeck
					]) { deck in
						DeckCell(
							deck: deck,
							width: 165,
							content: EmptyView.init
						)
					}
				}
			}
		}
	}
}
#endif

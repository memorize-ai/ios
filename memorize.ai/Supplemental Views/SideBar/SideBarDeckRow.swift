import SwiftUI

struct SideBarDeckRow: View {
	@ObservedObject var deck: Deck
	
	@Binding var selectedDeck: Deck?
	
	var isSelected: Bool {
		guard let selectedDeck = selectedDeck else { return false }
		return selectedDeck == deck
	}
	
	var backgroundColor: Color {
		isSelected
			? .darkBlue
			: .lightGrayBackground
	}
	
	var body: some View {
		HStack {
			Group {
				if deck.imageLoadingState.didFail {
					Image(systemName: .exclamationmarkTriangle)
						.foregroundColor(.gray)
						.scaleEffect(1.5)
				} else if deck.hasImage {
					if deck.image == nil {
						ActivityIndicator(color: .gray)
					} else {
						deck.image?
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fill)
					}
				} else {
					Image(systemName: .questionmark)
						.foregroundColor(.gray)
						.scaleEffect(1.5)
				}
			}
			.frame(width: 40, height: 40)
			.clipShape(Circle())
			Text(deck.name)
				.font(.muli(.regular, size: 16))
				.foregroundColor(.darkGray)
			Spacer()
			if deck.userData?.isDue ?? false {
				SideBarDeckRowDueCardsBadge(
					count: deck.userData?.numberOfDueCards ?? 0
				)
			}
		}
		.padding(.leading)
		.padding(.vertical, 6)
		.background(backgroundColor)
		.onTapGesture {
			self.selectedDeck = self.deck
		}
	}
}

#if DEBUG
struct SideBarDeckRow_Previews: PreviewProvider {
	static var previews: some View {
		SideBarDeckRow(
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
				dateCreated: .init(),
				dateLastUpdated: .init()
			),
			selectedDeck: .constant(nil)
		)
	}
}
#endif

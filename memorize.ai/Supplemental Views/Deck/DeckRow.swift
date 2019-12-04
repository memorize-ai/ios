import SwiftUI

struct DeckRow: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var deck: Deck
	
	let unselectedBackgroundColor: Color
	let onClick: (() -> Void)?
	
	init(
		deck: Deck,
		unselectedBackgroundColor: Color,
		onClick: (() -> Void)? = nil
	) {
		self.deck = deck
		self.unselectedBackgroundColor = unselectedBackgroundColor
		self.onClick = onClick
	}
	
	func onTapGesture() {
		onClick?()
		currentStore.goToDecksView(withDeck: deck)
	}
	
	var isSelected: Bool {
		guard let selectedDeck = currentStore.selectedDeck else { return false }
		return selectedDeck == deck
	}
	
	var alternateImageForegroundColor: Color {
		isSelected ? .white : .gray
	}
	
	var backgroundColor: Color {
		isSelected
			? .darkBlue
			: unselectedBackgroundColor
	}
	
	var body: some View {
		HStack {
			Group {
				if deck.imageLoadingState.didFail {
					Image(systemName: .exclamationmarkTriangle)
						.foregroundColor(alternateImageForegroundColor)
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
						.foregroundColor(alternateImageForegroundColor)
						.scaleEffect(1.5)
				}
			}
			.frame(width: 40, height: 40)
			.clipShape(Circle())
			Text(deck.name)
				.font(.muli(isSelected ? .bold : .regular, size: 16))
				.foregroundColor(isSelected ? .white : .darkGray)
			Spacer()
			if deck.userData?.isDue ?? false {
				SideBarDeckRowDueCardsBadge(
					count: deck.userData?.numberOfDueCards ?? 0,
					isSelected: isSelected
				)
			}
		}
		.padding(.horizontal)
		.padding(.vertical, 6)
		.background(backgroundColor)
		.onTapGesture(perform: onTapGesture)
	}
}

#if DEBUG
struct DeckRow_Previews: PreviewProvider {
	static var previews: some View {
		DeckRow(
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
			unselectedBackgroundColor: .white
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

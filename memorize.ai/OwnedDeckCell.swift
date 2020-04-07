import SwiftUI

struct OwnedDeckCell: View {
	static let defaultWidth: CGFloat = 200
	static let imageAspectRatio: CGFloat = 3 / 5
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var deck: Deck
	
	let width: CGFloat
	let imageBackgroundColor: Color
	let noCardsDueEmoji: String
	
	init(
		deck: Deck,
		width: CGFloat = Self.defaultWidth,
		imageBackgroundColor: Color = .lightGrayBackground
	) {
		self.deck = deck
		self.width = width
		self.imageBackgroundColor = imageBackgroundColor
		noCardsDueEmoji = [
			"😃",
			"😇",
			"😌",
			"😘",
			"🥳",
			"💪"
		].randomElement()!
	}
	
	var cardsDueMessage: String {
		let count = deck.userData?.numberOfDueCards ?? 0
		let sections = deck.userData?.sections.reduce(0) { acc, section in
			acc + (section.value > 0 ? 1 : 0)
		} ?? 0
		
		return "\(count.formatted) card\(count == 1 ? "" : "s") due in \(sections) section\(sections == 1 ? "" : "s")"
	}
	
	var isDue: Bool {
		deck.userData?.isDue ?? false
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
							imageBackgroundColor
							Image(systemName: .exclamationmarkTriangle)
								.foregroundColor(.gray)
								.scaleEffect(1.5)
						}
					} else if deck.hasImage {
						if deck.image == nil {
							ZStack {
								imageBackgroundColor
								ActivityIndicator(color: .gray)
							}
						} else {
							deck.displayImage?
								.resizable()
								.renderingMode(.original)
								.aspectRatio(contentMode: .fit)
						}
					} else {
						Deck.DEFAULT_IMAGE
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fit)
					}
				}
				.frame(width: width, height: width * Self.imageAspectRatio)
				.clipped()
				.cornerRadius(8, corners: [.topLeft, .topRight])
				VStack(alignment: .leading) {
					Text(deck.name)
						.font(.muli(.bold, size: 13.5))
						.foregroundColor(.darkGray)
					Text(deck.subtitle)
						.font(.muli(.regular, size: 11))
						.foregroundColor(.lightGrayText)
						.lineLimit(1)
						.padding(.top, 4)
				}
				.alignment(.leading)
				.padding(.horizontal, 8)
				.padding(.top, 4)
				VStack(alignment: .leading, spacing: 10) {
					Text(isDue ? cardsDueMessage : "\(noCardsDueEmoji) Woohoo!")
						.font(.muli(.bold, size: 13.5))
						.foregroundColor(.lightGrayText)
						.shrinks(withLineLimit: 3)
					if isDue {
						ReviewViewNavigationLink(deck: deck) {
							CustomRectangle(
								background: Color.extraPurple,
								cornerRadius: 14
							) {
								Text("REVIEW")
									.font(.muli(.bold, size: 12))
									.foregroundColor(.white)
									.frame(width: 92, height: 28)
							}
						}
					}
				}
				.alignment(.leading)
				.padding(.horizontal)
				.padding(.vertical, 16)
			}
			.frame(width: width)
		}
		.onTapGesture {
			self.currentStore.goToDecksView(withDeck: self.deck)
		}
	}
}

#if DEBUG
struct OwnedDeckCell_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 30) {
			OwnedDeckCell(
				deck: PREVIEW_CURRENT_STORE.user.decks[0]
			)
			.environmentObject(PREVIEW_CURRENT_STORE)
			OwnedDeckCell(
				deck: PREVIEW_CURRENT_STORE.user.decks[1]
			)
			.environmentObject(PREVIEW_CURRENT_STORE)
		}
	}
}
#endif

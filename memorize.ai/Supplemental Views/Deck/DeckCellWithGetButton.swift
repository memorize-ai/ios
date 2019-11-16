import SwiftUI

struct DeckCellWithGetButton: View {
	@ObservedObject var deck: Deck
	@ObservedObject var user: User
	
	let width: CGFloat
	
	var hasDeck: Bool {
		user.hasDeck(deck)
	}
	
	var isGetLoading: Bool {
		deck.getLoadingState.isLoading
	}
	
	var buttonBackground: Color {
		hasDeck ? .white : .extraPurple
	}
	
	var buttonTextColor: Color {
		hasDeck ? .extraPurple : .white
	}
	
	func buttonAction() {
		_ = hasDeck
			? deck.remove(user: user)
			: deck.get(user: user)
	}
	
	var body: some View {
		DeckCell(deck: deck, width: width) {
			Button(action: buttonAction) {
				CustomRectangle(
					background: buttonBackground,
					borderColor: .extraPurple,
					borderWidth: hasDeck ? 1 : 0,
					cornerRadius: 16.5
				) {
					Group {
						if isGetLoading {
							ActivityIndicator(radius: 8)
						} else {
							Text(hasDeck ? "REMOVE" : "GET")
								.font(.muli(.bold, size: 12))
						}
					}
					.foregroundColor(buttonTextColor)
					.frame(height: 33)
					.frame(maxWidth: .infinity)
				}
				.padding([.horizontal, .bottom], 18)
				.padding(.top, 10)
			}
			.disabled(isGetLoading)
			.alert(isPresented: $deck.getLoadingState.didFail) {
				.init(
					title: .init(
						"Unable to \(hasDeck ? "remove" : "get") deck"
					),
					message: .init(
						deck.getLoadingState.errorMessage ?? "Unknown error"
					)
				)
			}
		}
	}
}

#if DEBUG
struct DeckCellWithGetButton_Previews: PreviewProvider {
	static var previews: some View {
		let deck1 = Deck(
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
		)
		return VStack(spacing: 20) {
			DeckCellWithGetButton(
				deck: deck1,
				user: .init(
					id: "0",
					name: "Ken Mueller",
					email: "kenmueller0@gmail.com",
					interests: [],
					numberOfDecks: 1,
					decks: [deck1]
				),
				width: 165
			)
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
				user: PREVIEW_CURRENT_STORE.user,
				width: 165
			)
		}
	}
}
#endif

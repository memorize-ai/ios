import SwiftUI

struct DeckCellWithGetButton: View {
	@ObservedObject var deck: Deck
	@ObservedObject var user: User
	
	let width: CGFloat
	let shouldManuallyModifyDecks: Bool
	let shouldShowRemoveAlert: Bool
	
	init(
		deck: Deck,
		user: User,
		width: CGFloat,
		shouldManuallyModifyDecks: Bool = false,
		shouldShowRemoveAlert: Bool = true
	) {
		self.deck = deck
		self.user = user
		self.width = width
		self.shouldManuallyModifyDecks = shouldManuallyModifyDecks
		self.shouldShowRemoveAlert = shouldShowRemoveAlert
	}
	
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
		if hasDeck {
			if shouldShowRemoveAlert {
				deck.showRemoveFromLibraryAlert(forUser: user) {
					guard self.shouldManuallyModifyDecks else { return }
					self.user.decks.removeAll { $0 == self.deck }
				}
			} else {
				deck.remove(user: user)
				if shouldManuallyModifyDecks {
					user.decks.removeAll { $0 == deck }
				}
			}
		} else {
			deck.get(user: user)
			if shouldManuallyModifyDecks {
				user.decks.append(deck)
			}
		}
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
		let deck1 = Deck._new(
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
			numberOfCards: 19640,
			creatorId: "0",
			dateCreated: .now,
			dateLastUpdated: .now
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
					xp: 0,
					decks: [deck1]
				),
				width: 165
			)
			DeckCellWithGetButton(
				deck: ._new(
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
					numberOfCards: 19640,
					creatorId: "0",
					dateCreated: .now,
					dateLastUpdated: .now
				),
				user: PREVIEW_CURRENT_STORE.user,
				width: 165
			)
		}
	}
}
#endif

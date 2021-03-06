import SwiftUI

struct DecksViewBottomControls: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var selectedDeck: Deck
	
	var isOwner: Bool {
		currentStore.user.id == selectedDeck.creatorId
	}
	
	var hasUnlockedCards: Bool {
		selectedDeck.numberOfUnlockedCards > 0
	}
	
	var isDue: Bool {
		selectedDeck.userData?.isDue ?? false
	}
	
	var numberOfDueCards: Int {
		selectedDeck.userData?.numberOfDueCards ?? 0
	}
	
	func button(text: String, backgroundColor: Color) -> some View {
		HStack {
			Spacer()
			Text(text)
				.font(.muli(.extraBold, size: 20))
				.foregroundColor(.white)
				.shrinks()
			Spacer()
		}
		.frame(height: 50)
		.background(backgroundColor)
	}
	
	var addCardsButton: some View {
		AddCardsViewNavigationLink(deck: selectedDeck) {
			button(text: "Add cards", backgroundColor: .init(#colorLiteral(red: 0.1333333333, green: 0.631372549, blue: 1, alpha: 1)))
		}
	}
	
	var cramButton: some View {
		CramViewNavigationLink(deck: selectedDeck) {
			button(text: "Cram", backgroundColor: .init(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)))
		}
	}
	
	var reviewButton: some View {
		ReviewViewNavigationLink(deck: selectedDeck) {
			button(
				text: "Review \(numberOfDueCards.formatted)",
				backgroundColor: .init(#colorLiteral(red: 0, green: 0.7647058824, blue: 0.4941176471, alpha: 1))
			)
		}
	}
	
	var body: some View {
		HStack(spacing: 0) {
			if isOwner {
				addCardsButton
			}
			if hasUnlockedCards {
				cramButton
			}
			if isDue {
				reviewButton
			}
		}
	}
}

#if DEBUG
struct DecksViewBottomControls_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewBottomControls(
			selectedDeck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

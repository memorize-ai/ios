import SwiftUI

struct DecksViewBottomControls: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var selectedDeck: Deck
	
	var isOwner: Bool {
		currentStore.user.id == selectedDeck.creatorId
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
				.minimumScaleFactor(0.1)
			Spacer()
		}
		.frame(height: 50)
		.background(backgroundColor)
	}
	
	var addCardsButton: some View {
		AddCardsViewNavigationLink(deck: selectedDeck) {
			button(text: "Add cards", backgroundColor: .darkRed)
		}
	}
	
	var learnButton: some View {
		NavigationLink(
			destination: EmptyView() // TODO: Change this
		) {
			button(text: "Learn", backgroundColor: .darkBlue)
		}
	}
	
	var reviewButton: some View {
		NavigationLink(
			destination: EmptyView() // TODO: Change this
		) {
			button(
				text: "Review • \(numberOfDueCards.formatted)",
				backgroundColor: .green
			)
		}
	}
	
	var body: some View {
		HStack {
			if isOwner {
				addCardsButton
			}
			learnButton
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

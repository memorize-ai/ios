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
	
	var body: some View {
		HStack {
			if isOwner {
				button(text: "Add cards", backgroundColor: .darkRed)
			}
			button(text: "Learn", backgroundColor: .darkBlue)
			if isDue {
				button(
					text: "Review • \(numberOfDueCards.formatted)",
					backgroundColor: .green
				)
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

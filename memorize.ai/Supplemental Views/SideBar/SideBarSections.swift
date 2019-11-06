import SwiftUI

struct SideBarSections: View {
	@ObservedObject var currentUser: User
	
	@Binding var selectedDeck: Deck?
	
	var body: some View {
		VStack {
			if !currentUser.dueDecks.isEmpty {
				SideBarSection(
					title: "Due",
					decks: currentUser.dueDecks,
					selectedDeck: $selectedDeck
				)
				SideBarSectionDivider()
			}
			if !currentUser.favoriteDecks.isEmpty {
				SideBarSection(
					title: "Favorites",
					decks: currentUser.favoriteDecks,
					selectedDeck: $selectedDeck
				)
				SideBarSectionDivider()
			}
			if !currentUser.decks.isEmpty {
				SideBarSection(
					title: "All",
					decks: currentUser.decks,
					selectedDeck: $selectedDeck
				)
			}
		}
	}
}

#if DEBUG
struct SideBarSections_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSections(
			currentUser: .init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com",
				interests: [],
				numberOfDecks: 0
			),
			selectedDeck: .constant(nil)
		)
	}
}
#endif

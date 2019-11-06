import SwiftUI

struct SideBarSections: View {
	@ObservedObject var currentUser: User
	
	var body: some View {
		VStack {
			if !currentUser.dueDecks.isEmpty {
				SideBarSection(
					title: "Due",
					decks: currentUser.dueDecks
				)
				SideBarSectionDivider()
			}
			if !currentUser.favoriteDecks.isEmpty {
				SideBarSection(
					title: "Favorites",
					decks: currentUser.favoriteDecks
				)
				SideBarSectionDivider()
			}
			if !currentUser.decks.isEmpty {
				SideBarSection(
					title: "All",
					decks: currentUser.decks
				)
			}
		}
	}
}

#if DEBUG
struct SideBarSections_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSections(currentUser: .init(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com",
			interests: [],
			numberOfDecks: 0
		))
	}
}
#endif

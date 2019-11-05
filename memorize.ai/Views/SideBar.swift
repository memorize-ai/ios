import SwiftUI

struct SideBar<Content: View>: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	let content: Content
	
	init(content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		HStack {
			VStack {
				ForEach(currentUserStore.user.decks) { deck in
					Text(deck.name)
				}
			}
			content
		}
	}
}

#if DEBUG
struct SideBar_Previews: PreviewProvider {
	static var previews: some View {
		SideBar {
			Text("Content")
		}
		.environmentObject(UserStore(.init(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com",
			interests: [],
			numberOfDecks: 0
		)))
	}
}
#endif

import SwiftUI

struct MainTabView: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	@State var selection = 0
	
	var body: some View {
		TabView(selection: $selection) {
			HomeView()
				.tabItem {
					Image(systemName: .exclamationmarkTriangle)
					Text("Home")
				}
				.tag(0)
			Text("Marketplace")
				.tabItem {
					Image(systemName: .exclamationmarkTriangle)
					Text("Market")
				}
				.tag(1)
			Text("Decks")
				.tabItem {
					Image(systemName: .exclamationmarkTriangle)
					Text("Decks")
				}
				.tag(2)
			Text("You")
				.tabItem {
					Image(systemName: .exclamationmarkTriangle)
					Text("You")
				}
				.tag(3)
		}
	}
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
	static var previews: some View {
		MainTabView()
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

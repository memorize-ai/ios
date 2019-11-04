import SwiftUI

struct HomeView: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	var body: some View {
		Text("Hello, \(currentUserStore.user.name)")
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
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

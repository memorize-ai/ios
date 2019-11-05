import SwiftUI

struct HomeView: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	@Binding var isSideBarShowing: Bool
	
	var body: some View {
		VStack(spacing: 20) {
			Button(action: {
				self.isSideBarShowing = true
			}) {
				Text("Show side bar")
			}
			Text("Hello, \(currentUserStore.user.name)")
		}
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(isSideBarShowing: .constant(false))
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

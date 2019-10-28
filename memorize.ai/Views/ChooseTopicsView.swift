import SwiftUI

struct ChooseTopicsView: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	var body: some View {
		Text("Choosing topics for \(currentUserStore.user.name)")
	}
}

#if DEBUG
struct ChooseTopicsView_Previews: PreviewProvider {
	static var previews: some View {
		ChooseTopicsView()
			.environmentObject(UserStore(.init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com"
			)))
	}
}
#endif

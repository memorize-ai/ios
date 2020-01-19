import SwiftUI

struct ReviewRecapView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		NavigationLink(
			destination: MainTabView(currentUser: currentStore.user)
				.environmentObject(currentStore)
				.navigationBarRemoved()
		) {
			Text("Continue")
		}
	}
}

#if DEBUG
struct ReviewRecapView_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

import SwiftUI

struct ProfileView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		VStack {
			Text(currentStore.user.email)
			Button(action: {
				self.currentStore.signOut()
			}) {
				Text("Sign out")
			}
			NavigateTo(
				InitialView(),
				when: $currentStore.signOutLoadingState.didSucceed
			)
		}
	}
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
	static var previews: some View {
		ProfileView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

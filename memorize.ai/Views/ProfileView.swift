import SwiftUI

struct ProfileView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		Text(currentStore.user.email)
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

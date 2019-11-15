import SwiftUI

struct HomeViewMyDecksSection: View {
	@ObservedObject var currentUser: User
	
	var body: some View {
		Text("My decks")
	}
}

#if DEBUG
struct HomeViewMyDecksSection_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewMyDecksSection(
			currentUser: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

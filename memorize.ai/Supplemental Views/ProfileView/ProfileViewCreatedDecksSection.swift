import SwiftUI

struct ProfileViewCreatedDecksSection: View {
	@ObservedObject var user: User
	
	var body: some View {
		Text(user.createdDecks.count.formatted)
			.onAppear {
				self.user.loadCreatedDecks()
			}
	}
}

#if DEBUG
struct ProfileViewCreatedDecksSection_Previews: PreviewProvider {
	static var previews: some View {
		ProfileViewCreatedDecksSection(
			user: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

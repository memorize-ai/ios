import SwiftUI

struct RecommendedDecksViewContent: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	var body: some View {
		EmptyView() // TODO: Change this
	}
}

#if DEBUG
struct RecommendedDecksViewContent_Previews: PreviewProvider {
	static var previews: some View {
		RecommendedDecksViewContent()
			.environmentObject(UserStore(.init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com",
				interests: []
			)))
	}
}
#endif

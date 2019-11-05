import SwiftUI

struct RecommendedDecksView: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	var body: some View {
		PostSignUpView(
			title: "Recommended decks",
			leadingButton: EmptyView(),
			leadingButtonIsBackButton: true,
			trailingButtonTitle: "DONE",
			trailingButtonDestination: MainTabView()
				.environmentObject(currentUserStore),
			content: RecommendedDecksViewContent()
		)
	}
}

#if DEBUG
struct RecommendedDecksView_Previews: PreviewProvider {
	static var previews: some View {
		RecommendedDecksView()
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

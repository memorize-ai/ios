import SwiftUI

struct RecommendedDecksView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		PostSignUpView(
			title: "Recommended decks",
			leadingButton: EmptyView(),
			leadingButtonIsBackButton: true,
			trailingButtonTitle: "DONE",
			trailingButtonDestination: MainTabView(
				currentUser: currentStore.user
			)
			.environmentObject(currentStore)
			.removeNavigationBar(),
			content: RecommendedDecksViewContent()
		)
	}
}

#if DEBUG
struct RecommendedDecksView_Previews: PreviewProvider {
	static var previews: some View {
		RecommendedDecksView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

import SwiftUI

struct RecommendedDecksView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		PostSignUpView(
			title: "Recommended decks",
			leadingButton: EmptyView(),
			leadingButtonIsBackButton: true,
			trailingButtonTitle: "DONE",
			trailingButtonDestination: MainTabView()
				.environmentObject(currentStore),
			content: RecommendedDecksViewContent()
		)
	}
}

#if DEBUG
struct RecommendedDecksView_Previews: PreviewProvider {
	static var previews: some View {
		RecommendedDecksView()
			.environmentObject(CurrentStore(user: .init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com",
				interests: [],
				numberOfDecks: 0
			)))
	}
}
#endif

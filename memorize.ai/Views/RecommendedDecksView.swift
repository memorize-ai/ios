import SwiftUI

struct RecommendedDecksView: View {
	var body: some View {
		PostSignUpView(
			title: "Test",
			leadingButton: EmptyView(),
			leadingButtonIsBackButton: true,
			trailingButtonTitle: "TEST",
			trailingButtonDestination: EmptyView(),
			content: RecommendedDecksViewContent()
		)
	}
}

#if DEBUG
struct RecommendedDecksView_Previews: PreviewProvider {
	static var previews: some View {
		RecommendedDecksView()
	}
}
#endif

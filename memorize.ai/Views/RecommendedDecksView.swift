import SwiftUI

struct RecommendedDecksView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var currentUserStore: UserStore
	
	var leadingButton: some View {
		Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}) {
			LeftArrowHead(height: 20)
		}
	}
	
	var body: some View {
		PostSignUpView(
			title: "Recommended decks",
			leadingButton: leadingButton,
			trailingButtonTitle: "DONE",
			trailingButtonDestination: HomeView(),
			content: RecommendedDecksViewContent(
				currentUserStore: currentUserStore
			)
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

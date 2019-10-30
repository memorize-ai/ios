import SwiftUI

struct ChooseTopicsView: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	var leadingButton: some View {
		NavigationLink(destination: HomeView()) {
			XButton(height: 20)
		}
	}
	
	var body: some View {
		PostSignUpView(
			title: "Choose your interests",
			leadingButton: leadingButton,
			trailingButtonTitle: "NEXT",
			trailingButtonDestination: RecommendedDecksView(),
			content: EmptyView() // TODO: Change this
		)
	}
}

#if DEBUG
struct ChooseTopicsView_Previews: PreviewProvider {
	static var previews: some View {
		ChooseTopicsView()
			.environmentObject(UserStore(.init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com"
			)))
	}
}
#endif

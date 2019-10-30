import SwiftUI

struct ChooseTopicsView: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	var body: some View {
		PostSignUpView(
			title: "Choose your interests",
			leadingButton: XButton(height: 20), // TODO: Add button
			trailingButtonTitle: "NEXT",
			trailingButtonDestination: EmptyView(), // TODO: Change this
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

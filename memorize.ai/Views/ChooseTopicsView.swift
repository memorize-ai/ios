import SwiftUI

struct ChooseTopicsView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var model: ChooseTopicsViewModel
	
	init(currentUser: User) {
		model = .init(currentUser: currentUser)
	}
	
	var leadingButton: some View {
		NavigationLink(destination: currentStore.rootDestination) {
			XButton(.transparentWhite, height: 15)
		}
	}
	
	var body: some View {
		PostSignUpView(
			title: "Choose your interests",
			leadingButton: leadingButton,
			leadingButtonIsBackButton: false,
			trailingButtonTitle: "NEXT",
			trailingButtonDestination: RecommendedDecksView()
				.environmentObject(currentStore)
				.navigationBarRemoved(),
			content: ChooseTopicsViewContent()
				.environmentObject(model)
		)
	}
}

#if DEBUG
struct ChooseTopicsView_Previews: PreviewProvider {
	static var previews: some View {
		let currentUser = User(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com",
			interests: [],
			numberOfDecks: 0,
			xp: 0
		)
		return ChooseTopicsView(currentUser: currentUser)
			.environmentObject(CurrentStore(
				user: currentUser,
				topics: [
					.init(id: "0", name: "HTML", category: .language),
					.init(id: "1", name: "Geography", category: .language),
					.init(id: "0", name: "HTML", category: .language),
					.init(id: "1", name: "Geography", category: .language),
					.init(id: "0", name: "HTML", category: .language),
					.init(id: "1", name: "Geography", category: .language),
					.init(id: "0", name: "HTML", category: .language),
					.init(id: "1", name: "Geography", category: .language),
					.init(id: "0", name: "HTML", category: .language),
					.init(id: "1", name: "Geography", category: .language),
					.init(id: "0", name: "HTML", category: .language),
					.init(id: "1", name: "Geography", category: .language),
					.init(id: "0", name: "HTML", category: .language),
					.init(id: "1", name: "Geography", category: .language)
				]
			))
	}
}
#endif

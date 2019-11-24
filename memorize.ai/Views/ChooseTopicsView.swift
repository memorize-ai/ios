import SwiftUI

struct ChooseTopicsView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let content: ChooseTopicsViewContent
	
	init(currentUser: User) {
		content = ChooseTopicsViewContent(
			currentUser: currentUser
		)
	}
	
	var leadingButton: some View {
		NavigationLink(
			destination: MainTabView(
				currentUser: currentStore.user
			)
			.environmentObject(currentStore)
		) {
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
				.environmentObject(currentStore),
			content: content
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
			xp: 930
		)
		return ChooseTopicsView(currentUser: currentUser)
			.environmentObject(CurrentStore(
				user: currentUser,
				topics: [
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML"),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography"),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography"),
					.init(id: "0", name: "HTML"),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML"),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic"))
				]
			))
	}
}
#endif

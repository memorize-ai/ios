import SwiftUI

struct ChooseTopicsView: View {
	@EnvironmentObject var current: CurrentStore
	
	let content: ChooseTopicsViewContent
	
	init(currentUser: User) {
		content = ChooseTopicsViewContent(
			currentUser: currentUser
		)
	}
	
	var leadingButton: some View {
		NavigationLink(
			destination: MainTabView()
				.environmentObject(current)
		) {
			XButton(height: 20)
		}
	}
	
	var body: some View {
		PostSignUpView(
			title: "Choose your interests",
			leadingButton: leadingButton,
			leadingButtonIsBackButton: false,
			trailingButtonTitle: "NEXT",
			trailingButtonDestination: RecommendedDecksView()
				.environmentObject(current),
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
			numberOfDecks: 0
		)
		return ChooseTopicsView(currentUser: currentUser)
			.environmentObject(CurrentStore(
				currentUser,
				topics: [
					.init(id: "0", name: "HTML", image: .init("HTMLTopic"), topDecks: []),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic"), topDecks: []),
					.init(id: "0", name: "HTML", image: nil, topDecks: []),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic"), topDecks: []),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic"), topDecks: []),
					.init(id: "1", name: "Geography", image: nil, topDecks: []),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic"), topDecks: []),
					.init(id: "1", name: "Geography", image: nil, topDecks: []),
					.init(id: "0", name: "HTML", image: nil, topDecks: []),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic"), topDecks: []),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic"), topDecks: []),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic"), topDecks: []),
					.init(id: "0", name: "HTML", image: nil, topDecks: []),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic"), topDecks: [])
				]
			))
	}
}
#endif

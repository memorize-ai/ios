import SwiftUI

struct ChooseTopicsView: View {	
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
			content: ChooseTopicsViewContent()
		)
	}
}

#if DEBUG
struct ChooseTopicsView_Previews: PreviewProvider {
	static var previews: some View {
		ChooseTopicsView()
			.environmentObject(UserStore(
				.init(
					id: "0",
					name: "Ken Mueller",
					email: "kenmueller0@gmail.com"
				),
				topics: [
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
					.init(id: "0", name: "HTML", image: .init("HTMLTopic")),
					.init(id: "1", name: "Geography", image: .init("GeographyTopic")),
				]
			))
	}
}
#endif

import SwiftUI

struct MainTabView: View {
	@State var isSideBarShowing = false
	@State var tabViewSelection = 0
	
	var body: some View {
		SideBar(isShowing: $isSideBarShowing) {
			TabView(selection: $tabViewSelection) {
				HomeView(isSideBarShowing: $isSideBarShowing)
					.tabItem {
						Image(systemName: .exclamationmarkTriangle)
						Text("Home")
					}
					.tag(0)
				Text("Marketplace")
					.tabItem {
						Image(systemName: .exclamationmarkTriangle)
						Text("Market")
					}
					.tag(1)
				Text("Decks")
					.tabItem {
						Image(systemName: .exclamationmarkTriangle)
						Text("Decks")
					}
					.tag(2)
				Text("You")
					.tabItem {
						Image(systemName: .exclamationmarkTriangle)
						Text("You")
					}
					.tag(3)
			}
		}
	}
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
	static var previews: some View {
		MainTabView()
			.environmentObject(UserStore(.init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com",
				interests: [],
				numberOfDecks: 4,
				decks: [
					.init(
						id: "0",
						topics: [],
						hasImage: true,
						image: .init("GeometryPrepDeck"),
						name: "Geometry Prep #1",
						subtitle: "Angles, lines, triangles and other polygons",
						numberOfViews: 1000000000,
						numberOfUniqueViews: 200000,
						numberOfRatings: 12400,
						averageRating: 4.5,
						numberOfDownloads: 196400,
						dateCreated: .init(),
						dateLastUpdated: .init(),
						userData: .init(
							dateAdded: .init(),
							isFavorite: false,
							numberOfDueCards: 2
						)
					),
					.init(
						id: "1",
						topics: [],
						hasImage: true,
						image: .init("GeometryPrepDeck"),
						name: "Geometry Prep #2",
						subtitle: "Angles, lines, triangles and other polygons",
						numberOfViews: 1000000000,
						numberOfUniqueViews: 200000,
						numberOfRatings: 12400,
						averageRating: 4.5,
						numberOfDownloads: 196400,
						dateCreated: .init(),
						dateLastUpdated: .init(),
						userData: .init(
							dateAdded: .init(),
							isFavorite: true,
							numberOfDueCards: 0
						)
					),
					.init(
						id: "2",
						topics: [],
						hasImage: true,
						image: .init("GeometryPrepDeck"),
						name: "Geometry Prep #3",
						subtitle: "Angles, lines, triangles and other polygons",
						numberOfViews: 1000000000,
						numberOfUniqueViews: 200000,
						numberOfRatings: 12400,
						averageRating: 4.5,
						numberOfDownloads: 196400,
						dateCreated: .init(),
						dateLastUpdated: .init()
					),
					.init(
						id: "3",
						topics: [],
						hasImage: true,
						image: .init("GeometryPrepDeck"),
						name: "Geometry Prep #4",
						subtitle: "Angles, lines, triangles and other polygons",
						numberOfViews: 1000000000,
						numberOfUniqueViews: 200000,
						numberOfRatings: 12400,
						averageRating: 4.5,
						numberOfDownloads: 196400,
						dateCreated: .init(),
						dateLastUpdated: .init(),
						userData: .init(
							dateAdded: .init(),
							isFavorite: true,
							numberOfDueCards: 1
						)
					)
				]
			)))
	}
}
#endif

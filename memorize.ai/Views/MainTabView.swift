import SwiftUI

struct MainTabView: View {
	enum Selection {
		case home
		case marketplace
		case decks
		case you
	}
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@State var isSideBarShowing = false
	@State var tabViewSelection = Selection.home
	
	var body: some View {
		NavigationView {
			SideBar(isShowing: $isSideBarShowing) {
				TabView(selection: $tabViewSelection) {
					HomeView(isSideBarShowing: $isSideBarShowing)
						.tabItem {
							Image(systemName: .exclamationmarkTriangle)
							Text("Home")
						}
						.tag(Selection.home)
					Text("Marketplace")
						.tabItem {
							Image(systemName: .exclamationmarkTriangle)
							Text("Marketplace")
						}
						.tag(Selection.marketplace)
					Text("Decks")
						.tabItem {
							Image(systemName: .exclamationmarkTriangle)
							Text("Decks")
						}
						.tag(Selection.decks)
					Text("You")
						.tabItem {
							Image(systemName: .exclamationmarkTriangle)
							Text("You")
						}
						.tag(Selection.you)
				}
			}
			.removeNavigationBar()
		}
		.statusBar(hidden: isSideBarShowing)
		.animation(.linear(duration: 0.2))
		.onAppear {
			self.currentStore.loadUser()
			self.currentStore.user.loadDecks()
		}
	}
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
	static var previews: some View {
		let failedDeck = Deck(
			id: "6",
			topics: [],
			hasImage: true,
			name: "Geometry Prep #7",
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
				numberOfDueCards: 12
			)
		)
		failedDeck.imageLoadingState.fail(message: "Self-invoked")
		return MainTabView()
			.environmentObject(CurrentStore(user: .init(
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
							numberOfDueCards: 23
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
							numberOfDueCards: 36
						)
					),
					.init(
						id: "4",
						topics: [],
						hasImage: false,
						name: "Geometry Prep #5",
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
							numberOfDueCards: 568
						)
					),
					.init(
						id: "5",
						topics: [],
						hasImage: true,
						name: "Geometry Prep #6",
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
					),
					failedDeck
				]
			)))
	}
}
#endif

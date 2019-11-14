import SwiftUI
import SwiftUIX

struct MainTabView: View {
	enum Selection {
		case home
		case market
		case decks
		case profile
	}
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@State var isSideBarShowing = false
	@State var tabViewSelection = Selection.home
	
	var tabBarItems: some View {
		HStack(alignment: .bottom) {
			Spacer()
			MainTabViewItem(
				title: "Home",
				isSelected: tabViewSelection == .home,
				selectedContent: Image.selectedHomeTabBarItem
					.resizable(),
				unselectedContent: Image.homeTabBarItem
					.resizable()
			)
			.onTapGesture {
				self.tabViewSelection = .home
			}
			Spacer()
			MainTabViewItem(
				title: "Market",
				isSelected: tabViewSelection == .market,
				selectedContent: Image.selectedMarketTabBarItem
					.resizable()
					.scaleEffect(0.9)
					.offset(y: 4),
				unselectedContent: Image.marketTabBarItem
					.resizable()
					.scaleEffect(0.9)
					.offset(y: 4)
			)
			.onTapGesture {
				self.tabViewSelection = .market
			}
			Spacer()
			MainTabViewItem(
				title: "Decks",
				isSelected: tabViewSelection == .decks,
				selectedContent: Image.selectedDecksTabBarItem
					.resizable(),
				unselectedContent: Image.decksTabBarItem
					.resizable()
			)
			.onTapGesture {
				self.tabViewSelection = .decks
			}
			Spacer()
			MainTabViewItem(
				title: "You",
				isSelected: tabViewSelection == .profile,
				selectedContent: Image.selectedProfileTabBarItem
					.resizable()
					.scaleEffect(0.9)
					.offset(y: 3),
				unselectedContent: Image.profileTabBarItem
					.resizable()
					.scaleEffect(0.9)
					.offset(y: 3)
			)
			.onTapGesture {
				self.tabViewSelection = .profile
			}
			Spacer()
		}
	}
	
	var body: some View {
		NavigationView {
			SideBar(isShowing: $isSideBarShowing) {
				VStack(spacing: 0) {
					ZStack {
						Color.lightGrayBackground
							.edgesIgnoringSafeArea([.horizontal, .top])
						SwitchOver(tabViewSelection)
							.case(.home) {
								HomeView(isSideBarShowing: $isSideBarShowing)
							}
							.case(.market) {
								Text("Market") // TODO: Change to a custom view
							}
							.case(.decks) {
								Text("Decks") // TODO: Change to a custom view
							}
							.case(.profile) {
								Text("You") // TODO: Change to a custom view
						}
					}
					Rectangle()
						.fill(Color.lightGrayLine.opacity(0.5))
						.frame(height: 1)
					ZStack {
						Color.lightGray
							.edgesIgnoringSafeArea(.all)
						tabBarItems
					}
					.frame(height: 72)
				}
			}
			.removeNavigationBar()
		}
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

import SwiftUI

struct SideBar<Content: View>: View {
	let extendedWidth = SCREEN_SIZE.width - 36
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@State var searchText = ""
	@State var selectedDeck: Deck?
	
	@Binding var isShowing: Bool
	
	let content: Content
	
	init(isShowing: Binding<Bool>, content: () -> Content) {
		_isShowing = isShowing
		self.content = content()
	}
	
	func hide() {
		withAnimation(SIDE_BAR_ANIMATION) {
			isShowing = false
		}
	}
	
	var body: some View {
		ZStack(alignment: .leading) {
			ZStack {
				content
				Color.black
					.opacity(isShowing ? 0.3954 : 0)
					.onTapGesture(perform: hide)
					.edgesIgnoringSafeArea(.all)
			}
			.offset(x: isShowing ? extendedWidth : 0)
			ZStack {
				Color.lightGrayBackground
					.shadow(
						color: .black,
						radius: isShowing ? 5 : 0,
						x: isShowing ? -3 : 0
					)
				VStack(alignment: .leading, spacing: 18) {
					ZStack(alignment: .top) {
						SideBarTopGradient(width: extendedWidth)
						SearchBar(
							$searchText,
							placeholder: "Decks",
							internalPadding: 12
						)
						.padding([.horizontal, .top])
					}
					ScrollView {
						SideBarSections(
							currentUser: currentStore.user,
							selectedDeck: $selectedDeck,
							searchText: searchText
						)
					}
				}
			}
			.frame(width: extendedWidth)
			.frame(maxHeight: .infinity)
			.offset(x: isShowing ? 0 : -extendedWidth)
			.edgesIgnoringSafeArea(.all)
		}
	}
}

#if DEBUG
struct SideBar_Previews: PreviewProvider {
	static var previews: some View {
		SideBar(isShowing: .constant(true)) {
			Text("Content")
		}
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

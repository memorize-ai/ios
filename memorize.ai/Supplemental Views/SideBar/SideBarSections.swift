import SwiftUI

struct SideBarSections: View {
	@ObservedObject var currentUser: User
	
	var body: some View {
		VStack {
			SideBarSection(title: "Due")
			SideBarSection(title: "Favorites")
			SideBarSection(title: "All")
		}
	}
}

#if DEBUG
struct SideBarSections_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSections(currentUser: .init(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com",
			interests: [],
			numberOfDecks: 0
		))
	}
}
#endif

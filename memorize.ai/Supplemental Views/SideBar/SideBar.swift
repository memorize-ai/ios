import SwiftUI

struct SideBar<Content: View>: View {
	let extendedWidth = SCREEN_SIZE.width - 36
	
	@EnvironmentObject var currentUserStore: UserStore
	
	@State var searchText = ""
	
	@Binding var isShowing: Bool
	
	let content: Content
	
	init(isShowing: Binding<Bool>, content: () -> Content) {
		_isShowing = isShowing
		self.content = content()
	}
	
	var body: some View {
		ZStack(alignment: .leading) {
			ZStack {
				content
				if isShowing {
					Color.black
						.opacity(0.3954)
						.onTapGesture {
							self.isShowing = false
						}
				}
			}
			.offset(x: isShowing ? extendedWidth : 0)
			ZStack {
				Color.lightGrayBackground
					.shadow(
						color: .black,
						radius: isShowing ? 5 : 0,
						x: isShowing ? -3 : 0
					)
				VStack(alignment: .leading) {
					ZStack(alignment: .top) {
						SideBarTopGradient(width: extendedWidth)
						SearchBar(
							$searchText,
							placeholder: "Decks",
							internalPadding: 12
						)
						.padding([.horizontal, .top])
					}
					Group {
						SideBarSection(title: "Due")
						SideBarSection(title: "Starred")
						SideBarSection(title: "All")
					}
					.padding(.horizontal)
					Spacer()
				}
			}
			.frame(width: extendedWidth)
			.frame(maxHeight: .infinity)
			.offset(x: isShowing ? 0 : -extendedWidth)
		}
		.edgesIgnoringSafeArea(.all)
	}
}

#if DEBUG
struct SideBar_Previews: PreviewProvider {
	static var previews: some View {
		SideBar(isShowing: .constant(true)) {
			Text("Content")
		}
		.environmentObject(UserStore(.init(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com",
			interests: [],
			numberOfDecks: 0
		)))
	}
}
#endif

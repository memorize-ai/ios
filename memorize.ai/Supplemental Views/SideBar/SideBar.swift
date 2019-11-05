import SwiftUI

struct SideBar<Content: View>: View {
	let extendedWidth = SCREEN_SIZE.width - 36
	
	@EnvironmentObject var currentUserStore: UserStore
	
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
				VStack {
					ZStack(alignment: .top) {
						SideBarTopGradient(width: extendedWidth)
						// TODO: Add search bar here
					}
					ForEach(currentUserStore.user.decks) { deck in
						Text(deck.name)
					}
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

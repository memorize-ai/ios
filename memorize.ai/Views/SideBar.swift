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
	
	var offset: CGFloat {
		isShowing ? extendedWidth : 0
	}
	
	var body: some View {
		ZStack(alignment: .leading) {
			ZStack {
				content
				if isShowing {
					Color.black.opacity(0.3954)
				}
			}
			.offset(x: offset)
			ZStack {
				Color.lightGrayBackground
					.shadow(color: .black, radius: 5, x: -1)
				VStack {
					ForEach(currentUserStore.user.decks) { deck in
						Text(deck.name)
					}
				}
			}
			.frame(width: offset)
			.frame(maxHeight: .infinity)
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

import SwiftUI

struct ShowSideBarButton<Content: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let content: Content
	
	init(content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		Button(action: {
			withAnimation(SIDE_BAR_ANIMATION) {
				self.currentStore.isSideBarShowing = true
			}
		}) {
			content
		}
	}
}

#if DEBUG
struct ShowSideBarButton_Previews: PreviewProvider {
	static var previews: some View {
		ShowSideBarButton {
			HamburgerMenu()
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

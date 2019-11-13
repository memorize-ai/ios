import SwiftUI

struct ShowSideBarButton<Content: View>: View {
	@Binding var isShowing: Bool
	
	let content: Content
	
	init(_ isShowing: Binding<Bool>, content: () -> Content) {
		_isShowing = isShowing
		self.content = content()
	}
	
	var body: some View {
		Button(action: {
			withAnimation(SIDE_BAR_ANIMATION) {
				self.isShowing = true
			}
		}) {
			content
		}
	}
}

#if DEBUG
struct ShowSideBarButton_Previews: PreviewProvider {
	static var previews: some View {
		ShowSideBarButton(.constant(false)) {
			HamburgerMenu()
		}
	}
}
#endif

import SwiftUI

struct HamburgerMenu: View {
	@Binding var isSideBarShowing: Bool
	
	let color: Color
	
	init(_ isSideBarShowing: Binding<Bool>, color: Color = .white) {
		_isSideBarShowing = isSideBarShowing
		self.color = color
	}
	
	var bar: some View {
		Rectangle()
			.frame(height: 2)
	}
	
	var body: some View {
		VStack(spacing: 3) {
			bar
			bar
			bar
		}
		.foregroundColor(color)
		.frame(width: 18)
	}
}

#if DEBUG
struct HamburgerMenu_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.gray
				.edgesIgnoringSafeArea(.all)
			HamburgerMenu(.constant(true))
		}
	}
}
#endif

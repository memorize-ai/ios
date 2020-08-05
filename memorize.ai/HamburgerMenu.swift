import SwiftUI

struct HamburgerMenu: View {
	let color: Color
	
	init(color: Color = .white) {
		self.color = color
	}
	
	var bar: some View {
		Rectangle()
			.frame(height: 2.5)
	}
	
	var body: some View {
		VStack(spacing: 3.5) {
			bar
			bar
			bar
		}
		.foregroundColor(color)
		.frame(width: 20)
	}
}

#if DEBUG
struct HamburgerMenu_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.gray
				.edgesIgnoringSafeArea(.all)
			HamburgerMenu()
		}
	}
}
#endif

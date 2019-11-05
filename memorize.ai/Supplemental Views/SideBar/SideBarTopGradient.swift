import SwiftUI

struct SideBarTopGradient: View {
	let width: CGFloat
	
	var body: some View {
		Text("SideBarTopGradient")
	}
}

#if DEBUG
struct SideBarTopGradient_Previews: PreviewProvider {
	static var previews: some View {
		SideBarTopGradient(width: SCREEN_SIZE.width - 36)
	}
}
#endif

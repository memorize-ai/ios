import SwiftUI

struct SideBarSectionDivider: View {
	var body: some View {
		Rectangle()
			.foregroundColor(.lightGrayBorder)
			.frame(height: 1)
			.padding(.horizontal)
			.padding(.bottom, 10)
	}
}

#if DEBUG
struct SideBarSectionDivider_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSectionDivider()
	}
}
#endif

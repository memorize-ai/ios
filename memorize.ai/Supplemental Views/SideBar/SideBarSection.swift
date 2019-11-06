import SwiftUI

struct SideBarSection: View {
	let title: String
	
	var body: some View {
		VStack {
			SideBarSectionTitle(title)
		}
	}
}

#if DEBUG
struct SideBarSection_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSection(title: "Due")
	}
}
#endif

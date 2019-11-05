import SwiftUI

struct SideBar<Content: View>: View {
	let content: Content
	
	init(content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		HStack {
			Text("SideBar")
			content
		}
	}
}

#if DEBUG
struct SideBar_Previews: PreviewProvider {
	static var previews: some View {
		SideBar {
			Text("Content")
		}
	}
}
#endif

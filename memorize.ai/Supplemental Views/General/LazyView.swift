import SwiftUI

struct LazyView<Content: View>: View {
	let content: () -> Content
	
	var body: some View {
		content()
	}
}

#if DEBUG
struct LazyView_Previews: PreviewProvider {
	static var previews: some View {
		LazyView {
			Text("Lazy view")
		}
	}
}
#endif

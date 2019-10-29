import SwiftUI

struct PostSignUpView<Content: View>: View {
	let title: String
	let content: Content
	
	init(title: String, content: () -> Content) {
		self.title = title
		self.content = content()
	}
	
	var body: some View {
		VStack {
			Text(title)
			content
		}
	}
}

#if DEBUG
struct PostSignUpView_Previews: PreviewProvider {
	static var previews: some View {
		PostSignUpView(title: "Choose your interests") {
			EmptyView()
		}
	}
}
#endif

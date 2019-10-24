import SwiftUI

struct AuthenticationViewContentBox<Content: View>: View {
	let title: String
	let content: Content
	
	var body: some View {
		GeometryReader { geometry in
			CustomRectangle(
				borderColor: .lightGray,
				borderWidth: 1.5,
				cornerRadius: 5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack {
					Text(self.title)
						.font(.muli(.bold, size: 28))
						.foregroundColor(.darkGray)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.top, 35)
					self.content
					Spacer()
				}
				.padding(.horizontal, 16)
				.frame(
					width: geometry.size.width - 96,
					height: geometry.size.height - 212
				)
			}
		}
	}
}

#if DEBUG
struct AuthenticationViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		AuthenticationViewContentBox(
			title: "Welcome back",
			content: EmptyView()
		)
	}
}
#endif

import SwiftUI

struct AuthenticationViewContentBox<Content: View>: View {
	let title: String
	let content: Content
	
	var body: some View {
		CustomRectangle(
			borderColor: .lightGray,
			borderWidth: 1.5,
			cornerRadius: 5,
			shadowRadius: 5,
			shadowYOffset: 5
		) {
			VStack {
				Text(title)
					.font(.muli(.bold, size: 28))
					.foregroundColor(.darkGray)
					.align(to: .leading)
					.padding(.top, 35)
				content
				Spacer()
			}
			.padding(.horizontal, 16)
			.frame(
				width: SCREEN_SIZE.width - 96,
				height: SCREEN_SIZE.height - 212
			)
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

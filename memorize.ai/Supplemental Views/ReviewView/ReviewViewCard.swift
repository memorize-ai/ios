import SwiftUI

struct ReviewViewCard<Content: View>: View {
	let width = SCREEN_SIZE.width - 8 * 2
	let height = SCREEN_SIZE.height * 501 / 667
	
	let scale: CGFloat
	let content: Content
	
	init(
		scale: CGFloat = 1,
		content: () -> Content
	) {
		self.scale = scale
		self.content = content()
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5,
			shadowRadius: 5,
			shadowYOffset: 5
		) {
			content
				.frame(
					width: width * scale,
					height: height * scale
				)
		}
	}
}

#if DEBUG
struct ReviewViewCard_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewCard {
			Text("")
		}
	}
}
#endif

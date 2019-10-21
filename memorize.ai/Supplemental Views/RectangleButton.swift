import SwiftUI

struct RectangleButton<Content: View>: View {
	let backgroundColor: Color
	let borderColor: Color
	let borderWidth: CGFloat
	let cornerRadius: CGFloat
	let action: () -> Void
	let content: () -> Content
	
	init(
		backgroundColor: Color = .white,
		borderColor: Color = .white,
		borderWidth: CGFloat = 0,
		cornerRadius: CGFloat = 5,
		action: @escaping () -> Void,
		content: @escaping () -> Content
	) {
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
		self.action = action
		self.content = content
	}
	
	var body: some View {
		Button(action: action) {
			content()
				.padding(.horizontal, 37)
				.padding(.vertical)
				.background(backgroundColor)
				.cornerRadius(cornerRadius)
				.border(borderColor, width: borderWidth)
		}
	}
}

#if DEBUG
struct RectangleButton_Previews: PreviewProvider {
	static var previews: some View {
		RectangleButton(action: {}) {
			Text("SIGN UP")
				.bold()
				.foregroundColor(.purple)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.gray)
		.edgesIgnoringSafeArea(.all)
	}
}
#endif

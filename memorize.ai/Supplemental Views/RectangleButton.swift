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
		let roundedRectangle = RoundedRectangle(cornerRadius: cornerRadius)
		return Button(action: action) {
			content()
				.background(
					backgroundColor
						.clipShape(roundedRectangle)
				)
				.overlay(
					roundedRectangle
						.stroke(borderColor, lineWidth: borderWidth)
				)
		}
	}
}

#if DEBUG
struct RectangleButton_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			RectangleButton(action: {}) {
				Text("SIGN UP")
					.frame(maxWidth: 132, maxHeight: 40)
					.font(.muli(.bold, size: 14))
					.foregroundColor(.darkBlue)
			}
			RectangleButton(borderColor: .darkBlue, borderWidth: 3, action: {}) {
				Text("SIGN UP")
					.frame(maxWidth: 132, maxHeight: 40)
					.font(.muli(.bold, size: 14))
					.foregroundColor(.darkBlue)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.gray)
		.edgesIgnoringSafeArea(.all)
	}
}
#endif

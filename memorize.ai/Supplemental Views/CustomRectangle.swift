import SwiftUI

struct CustomRectangle<Content: View>: View {
	let backgroundColor: Color
	let borderColor: Color
	let borderWidth: CGFloat
	let cornerRadius: CGFloat
	let content: Content
	
	init(
		backgroundColor: Color = .white,
		borderColor: Color = .white,
		borderWidth: CGFloat = 0,
		cornerRadius: CGFloat = 5,
		content: () -> Content
	) {
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
		self.content = content()
	}
	
	var body: some View {
		let roundedRectangle = RoundedRectangle(cornerRadius: cornerRadius)
		return content
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

#if DEBUG
struct CustomRectangle_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			CustomRectangle {
				Text("SIGN UP")
					.frame(maxWidth: 132, maxHeight: 40)
					.font(.muli(.bold, size: 14))
					.foregroundColor(.darkBlue)
			}
			CustomRectangle(borderColor: .darkBlue, borderWidth: 3) {
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

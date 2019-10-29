import SwiftUI

struct CustomRectangle<Content: View>: View {
	let backgroundColor: Color
	let borderColor: Color
	let borderWidth: CGFloat
	let cornerRadius: CGFloat
	let shadowColor: Color
	let shadowRadius: CGFloat
	let shadowXOffset: CGFloat
	let shadowYOffset: CGFloat
	let content: Content
	
	init(
		backgroundColor: Color = .white,
		borderColor: Color = .white,
		borderWidth: CGFloat = 0,
		cornerRadius: CGFloat = 5,
		shadowColor: Color = .grayShadow,
		shadowRadius: CGFloat = 0,
		shadowXOffset: CGFloat = 0,
		shadowYOffset: CGFloat = 0,
		content: () -> Content
	) {
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
		self.shadowColor = shadowColor
		self.shadowRadius = shadowRadius
		self.shadowXOffset = shadowXOffset
		self.shadowYOffset = shadowYOffset
		self.content = content()
	}
	
	var body: some View {
		let roundedRectangle = RoundedRectangle(cornerRadius: cornerRadius)
		return content
			.background(
				backgroundColor
					.clipShape(roundedRectangle)
					.shadow(
						color: shadowColor,
						radius: shadowRadius,
						x: shadowXOffset,
						y: shadowYOffset
					)
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
					.frame(maxWidth: 132)
					.frame(height: 40)
					.font(.muli(.bold, size: 14))
					.foregroundColor(.darkBlue)
			}
			CustomRectangle(borderColor: .darkBlue, borderWidth: 3) {
				Text("SIGN UP")
					.frame(maxWidth: 132)
					.frame(height: 40)
					.font(.muli(.bold, size: 14))
					.foregroundColor(.darkBlue)
			}
		}
		.align(to: .center)
		.background(Color.gray)
		.edgesIgnoringSafeArea(.all)
	}
}
#endif

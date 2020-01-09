import SwiftUI

struct CustomRectangle<Background: View, Content: View>: View {
	let background: Background
	let borderColor: Color
	let borderWidth: CGFloat
	let cornerRadius: CGFloat
	let shadowColor: Color
	let shadowRadius: CGFloat
	let shadowXOffset: CGFloat
	let shadowYOffset: CGFloat
	let content: Content
	
	init(
		background: Background,
		borderColor: Color = .white,
		borderWidth: CGFloat = 0,
		cornerRadius: CGFloat = 5,
		shadowColor: Color = .grayShadow,
		shadowRadius: CGFloat = 0,
		shadowXOffset: CGFloat = 0,
		shadowYOffset: CGFloat = 0,
		content: () -> Content
	) {
		self.background = background
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
				background
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
			CustomRectangle(background: Color.white) {
				Text("SIGN UP")
					.frame(maxWidth: 132)
					.frame(height: 40)
					.font(.muli(.bold, size: 14))
					.foregroundColor(.darkBlue)
			}
			CustomRectangle(
				background: Color.white,
				borderColor: .darkBlue,
				borderWidth: 3
			) {
				Text("SIGN UP")
					.frame(maxWidth: 132)
					.frame(height: 40)
					.font(.muli(.bold, size: 14))
					.foregroundColor(.darkBlue)
			}
		}
		.alignment(.center)
		.background(Color.gray)
		.edgesIgnoringSafeArea(.all)
	}
}
#endif

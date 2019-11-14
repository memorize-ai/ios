import SwiftUI

struct ActivityIndicator: View {
	@State var shouldSpin = false
	
	let radius: CGFloat
	let color: Color
	let thickness: CGFloat
	let degrees: Double
	let rotationDuration: Double
	
	init(
		radius: CGFloat = 10,
		color: Color = .white,
		thickness: CGFloat = 3,
		degrees: Double = 130,
		rotationDuration: Double = 0.8
	) {
		self.radius = radius
		self.color = color
		self.thickness = thickness
		self.degrees = degrees
		self.rotationDuration = rotationDuration
	}
	
	var body: some View {
		let dimension = radius * 2
		return Path { path in
			path.addArc(
				center: .init(x: radius, y: radius),
				radius: radius,
				startAngle: .zero,
				endAngle: .degrees(degrees),
				clockwise: false
			)
		}
		.stroke(color, lineWidth: thickness)
		.frame(width: dimension, height: dimension)
		.onAppear {
			self.shouldSpin = true
		}
		.rotationEffect(.degrees(shouldSpin ? 360 : 0))
		.animation(
			Animation
				.linear(duration: rotationDuration)
				.repeatForever(autoreverses: false)
		)
	}
}

#if DEBUG
struct ActivityIndicator_Previews: PreviewProvider {
	static var previews: some View {
		ActivityIndicator(color: .blue)
	}
}
#endif

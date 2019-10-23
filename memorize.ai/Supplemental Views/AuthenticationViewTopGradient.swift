import SwiftUI

struct AuthenticationViewTopGradient: View {
	static let fullHeightRatio: CGFloat = 339.6 / 667
	static let contentHeightDifference: CGFloat = 80
	
	let gradient: [Color]
	let height: CGFloat
	
	init(_ gradient: [Color], height: CGFloat) {
		self.gradient = gradient
		self.height = height
	}
	
	init(_ gradient: [Color], fullHeight: CGFloat) {
		self.init(gradient, height: fullHeight * Self.fullHeightRatio)
	}
	
	var body: some View {
		GeometryReader { geometry in
			Path { path in
				let width = geometry.size.width
				path.addLines([
					.init(x: 0, y: self.height),
					.init(x: 0, y: 0),
					.init(x: width, y: 0),
					.init(x: width, y: self.height - Self.contentHeightDifference)
				])
			}
			.fill(LinearGradient(
				gradient: .init(colors: self.gradient),
				startPoint: .top,
				endPoint: .bottom
			))
		}
		.frame(height: height)
	}
}

#if DEBUG
struct AuthenticationViewTopGradient_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			AuthenticationViewTopGradient([
				.bluePurple,
				.lightGreen
			], fullHeight: geometry.size.height)
		}
		.edgesIgnoringSafeArea(.all)
	}
}
#endif

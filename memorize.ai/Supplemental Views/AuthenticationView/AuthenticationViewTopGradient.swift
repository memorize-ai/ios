import SwiftUI

struct AuthenticationViewTopGradient: View {
	static let fullHeightRatio: CGFloat = 339.6 / 667
	static let contentHeightDifference: CGFloat = 80
	
	let gradient: [Color]
	let height: CGFloat
	
	init(
		_ gradient: Color...,
		height: CGFloat = SCREEN_SIZE.height * Self.fullHeightRatio
	) {
		self.gradient = gradient
		self.height = height
	}
	
	var body: some View {
		Path { path in
			let width = SCREEN_SIZE.width
			path.addLines([
				.init(x: 0, y: height),
				.init(x: 0, y: 0),
				.init(x: width, y: 0),
				.init(x: width, y: height - Self.contentHeightDifference)
			])
		}
		.fill(LinearGradient(
			gradient: .init(colors: gradient),
			startPoint: .top,
			endPoint: .bottom
		))
		.frame(height: height)
	}
}

#if DEBUG
struct AuthenticationViewTopGradient_Previews: PreviewProvider {
	static var previews: some View {
		AuthenticationViewTopGradient(
			.bluePurple,
			.lightGreen
		)
		.edgesIgnoringSafeArea(.all)
	}
}
#endif

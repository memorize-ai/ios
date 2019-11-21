import SwiftUI

struct AuthenticationViewTopGradient: View {
	static let fullHeightRatio: CGFloat = 339.6 / 667
	static let contentHeightDifference: CGFloat = 80
	
	let gradient: [Color]
	let height: CGFloat
	let addedHeight: CGFloat
	
	init(
		_ gradient: [Color],
		height: CGFloat = SCREEN_SIZE.height * Self.fullHeightRatio,
		addedHeight: CGFloat
	) {
		self.gradient = gradient
		self.height = height
		self.addedHeight = addedHeight
	}
	
	var body: some View {
		Path { path in
			let width = SCREEN_SIZE.width
			path.addLines([
				.init(x: 0, y: height + addedHeight),
				.zero,
				.init(x: width, y: 0),
				.init(
					x: width,
					y: height + addedHeight - Self.contentHeightDifference
				)
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
		AuthenticationViewTopGradient([
			.bluePurple,
			.lightGreen
		], addedHeight: 30)
		.edgesIgnoringSafeArea(.all)
	}
}
#endif

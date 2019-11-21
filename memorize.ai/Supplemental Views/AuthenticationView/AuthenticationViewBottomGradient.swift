import SwiftUI

struct AuthenticationViewBottomGradient: View {
	static let screenToWidthRatio: CGFloat = 251.93 / 375
	static let aspectRatio: CGFloat = 54 / 251.93
	
	let gradient: [Color]
	
	init(_ gradient: [Color]) {
		self.gradient = gradient
	}
	
	var width: CGFloat {
		SCREEN_SIZE.width * Self.screenToWidthRatio
	}
	
	var height: CGFloat {
		width * Self.aspectRatio
	}
	
	var body: some View {
		Path { path in
			path.addLines([
				.init(x: 0, y: height),
				.init(x: width, y: 0),
				.init(x: width, y: height)
			])
		}
		.fill(LinearGradient(
			gradient: .init(colors: gradient),
			startPoint: .top,
			endPoint: .bottom
		))
		.frame(width: width, height: height)
	}
}

#if DEBUG
struct AuthenticationViewBottomGradient_Previews: PreviewProvider {
	static var previews: some View {
		AuthenticationViewBottomGradient([
			.lightGreen,
			.bluePurple
		])
	}
}
#endif

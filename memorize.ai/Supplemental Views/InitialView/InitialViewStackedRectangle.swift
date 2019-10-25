import SwiftUI

struct InitialViewStackedRectangle: View {
	static let aspectRatio: CGFloat = 135 / 375
	static let contentHeight: CGFloat = 55
	
	let color: Color
	
	var body: some View {
		let width = SCREEN_SIZE.width
		let height = width * Self.aspectRatio
		return Path { path in
			path.addLines([
				.init(x: 0, y: height),
				.init(x: 0, y: height - Self.contentHeight),
				.init(x: width, y: 0),
				.init(x: width, y: Self.contentHeight)
			])
		}
		.fill(color)
		.frame(width: width, height: height)
	}
}

#if DEBUG
struct InitialViewStackedRectangle_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewStackedRectangle(color: .darkBlue)
	}
}
#endif

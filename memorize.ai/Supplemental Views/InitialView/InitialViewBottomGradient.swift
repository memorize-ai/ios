import SwiftUI

struct InitialViewBottomGradient: View {
	static let baseHeight: CGFloat = 171.64
	static let midHeight: CGFloat = 91.64
	
	let addedHeight: CGFloat
	
	var height: CGFloat {
		Self.baseHeight + addedHeight
	}
	
	var body: some View {
		Path { path in
			let width = SCREEN_SIZE.width
			path.addLines([
				.init(x: 0, y: height),
				.init(x: 0, y: Self.baseHeight - Self.midHeight),
				.init(x: width, y: 0),
				.init(x: width, y: height)
			])
		}
		.fill(LinearGradient(
			gradient: .init(colors: [.lightBlue, .mediumBlue]),
			startPoint: .top,
			endPoint: .bottom
		))
		.frame(height: height)
	}
}

#if DEBUG
struct InitialViewBottomGradient_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewBottomGradient(addedHeight: 30)
	}
}
#endif

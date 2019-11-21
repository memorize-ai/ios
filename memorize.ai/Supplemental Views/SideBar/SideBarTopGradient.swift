import SwiftUI

struct SideBarTopGradient: View {
	static let baseHeight: CGFloat = 108
	static let midHeight: CGFloat = 78
	
	let width: CGFloat
	let addedHeight: CGFloat
	
	var height: CGFloat {
		Self.baseHeight + addedHeight
	}
	
	var body: some View {
		Path { path in
			path.addLines([
				.init(x: 0, y: height),
				.zero,
				.init(x: width, y: 0),
				.init(
					x: width,
					y: Self.midHeight + addedHeight
				)
			])
		}
		.fill(LinearGradient(
			gradient: .init(colors: [
				.mediumBlue,
				.lightBlue
			]),
			startPoint: .top,
			endPoint: .bottom
		))
		.frame(width: width, height: height)
	}
}

#if DEBUG
struct SideBarTopGradient_Previews: PreviewProvider {
	static var previews: some View {
		SideBarTopGradient(
			width: SCREEN_SIZE.width - 36,
			addedHeight: 0
		)
	}
}
#endif

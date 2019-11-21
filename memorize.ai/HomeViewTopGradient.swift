import SwiftUI

struct HomeViewTopGradient: View {
	static let baseHeight = SCREEN_SIZE.height / 2.25
	static let heightDifference: CGFloat = 80.79
	
	let addedHeight: CGFloat
	
	var height: CGFloat {
		Self.baseHeight + addedHeight
	}
	
	var body: some View {
		Path { path in
			path.addLines([
				.init(x: 0, y: height),
				.zero,
				.init(x: SCREEN_SIZE.width, y: 0),
				.init(
					x: SCREEN_SIZE.width,
					y: height - Self.heightDifference
				)
			])
		}
		.fill(LinearGradient(
			gradient: .init(colors: [
				.extraBluePurple,
				.darkerLightBlue
			]),
			startPoint: .top,
			endPoint: .bottom
		))
		.frame(height: height)
	}
}

#if DEBUG
struct HomeViewTopGradient_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewTopGradient(addedHeight: 0)
	}
}
#endif

import SwiftUI

struct HomeViewTopGradient: View {
	static let baseHeight = SCREEN_SIZE.height / 2.25
	static let heightDifference: CGFloat = 80.79
	
	let colors: [Color]
	let addedHeight: CGFloat
	
	init(
		colors: [Color] = [.extraBluePurple, .darkerLightBlue],
		addedHeight: CGFloat
	) {
		self.colors = colors
		self.addedHeight = addedHeight
	}
	
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
			gradient: .init(colors: colors),
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

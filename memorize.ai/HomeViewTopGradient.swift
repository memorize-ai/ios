import SwiftUI

struct HomeViewTopGradient: View {
	static let height = SCREEN_SIZE.height / 2.25
	static let heightDifference: CGFloat = 80.79
	
	var body: some View {
		Path { path in
			path.addLines([
				.init(x: 0, y: Self.height),
				.zero,
				.init(x: SCREEN_SIZE.width, y: 0),
				.init(
					x: SCREEN_SIZE.width,
					y: Self.height - Self.heightDifference
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
		.frame(height: Self.height)
	}
}

#if DEBUG
struct HomeViewTopGradient_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewTopGradient()
	}
}
#endif

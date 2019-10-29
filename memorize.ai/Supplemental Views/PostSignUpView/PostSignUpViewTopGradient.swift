import SwiftUI

struct PostSignUpViewTopGradient: View {
	static let gradient: [Color] = [
		.extraBluePurple,
		.darkerLightBlue
	]
	static let midHeight = SCREEN_SIZE.height / 2
	static let height = midHeight + heightDifference
	static let heightDifference: CGFloat = 80
	
	var body: some View {
		Path { path in
			path.addLines([
				.init(x: 0, y: Self.height),
				.zero,
				.init(x: SCREEN_SIZE.width, y: 0),
				.init(x: SCREEN_SIZE.width, y: Self.midHeight)
			])
		}
		.fill(LinearGradient(
			gradient: .init(colors: Self.gradient),
			startPoint: .top,
			endPoint: .bottom
		))
		.frame(height: Self.height)
	}
}

#if DEBUG
struct PostSignUpViewTopGradient_Previews: PreviewProvider {
	static var previews: some View {
		PostSignUpViewTopGradient()
	}
}
#endif

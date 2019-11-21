import SwiftUI

struct PostSignUpViewTopGradient: View {
	static let gradient: [Color] = [
		.extraBluePurple,
		.darkerLightBlue
	]
	static let midHeight = SCREEN_SIZE.height / 2
	static let baseHeight = midHeight + heightDifference
	static let heightDifference: CGFloat = 80
	
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
				.init(x: SCREEN_SIZE.width, y: Self.midHeight + addedHeight)
			])
		}
		.fill(LinearGradient(
			gradient: .init(colors: Self.gradient),
			startPoint: .top,
			endPoint: .bottom
		))
		.frame(height: height)
	}
}

#if DEBUG
struct PostSignUpViewTopGradient_Previews: PreviewProvider {
	static var previews: some View {
		PostSignUpViewTopGradient(addedHeight: 30)
	}
}
#endif

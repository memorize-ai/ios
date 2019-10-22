import SwiftUI

struct InitialViewBottomGradient: View {
	static let height: CGFloat = 171.64
	static let midHeight: CGFloat = 91.64
	
	var body: some View {
		GeometryReader { geometry in
			Path { path in
				let width = geometry.size.width
				path.addLines([
					.init(x: 0, y: Self.midHeight),
					.init(x: width, y: 0),
					.init(x: width, y: Self.height),
					.init(x: 0, y: Self.height)
				])
			}
			.fill(LinearGradient(
				gradient: .init(colors: [.lightBlue, .mediumBlue]),
				startPoint: .init(x: 0.5, y: 0),
				endPoint: .init(x: 0.5, y: 1)
			))
		}
		.frame(height: Self.height)
	}
}

#if DEBUG
struct InitialViewBottomGradient_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewBottomGradient()
	}
}
#endif

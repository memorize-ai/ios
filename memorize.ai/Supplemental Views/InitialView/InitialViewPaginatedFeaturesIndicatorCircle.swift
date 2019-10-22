import SwiftUI

struct InitialViewPaginatedFeaturesIndicatorCircle: View {
	static let width: CGFloat = 10
	
	let active: Bool
	
	var body: some View {
		Circle()
			.frame(width: Self.width)
			.foregroundColor(Color.darkBlue.opacity(active ? 1 : 0.2))
	}
}

#if DEBUG
struct InitialViewPaginatedFeaturesIndicatorCircle_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			InitialViewPaginatedFeaturesIndicatorCircle(active: true)
			InitialViewPaginatedFeaturesIndicatorCircle(active: false)
		}
	}
}
#endif

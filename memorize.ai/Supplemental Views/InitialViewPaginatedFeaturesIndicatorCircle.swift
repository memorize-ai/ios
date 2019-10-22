import SwiftUI

struct InitialViewPaginatedFeaturesIndicatorCircle: View {
	let active: Bool
	
	var body: some View {
		Text("InitialViewPaginatedFeaturesIndicatorCircle")
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

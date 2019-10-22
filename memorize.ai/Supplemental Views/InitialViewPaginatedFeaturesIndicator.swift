import SwiftUI

struct InitialViewPaginatedFeaturesIndicator: View {
	let pageCount: Int
	let activePageIndex: Int
	
	var body: some View {
		Text("Pages: \(pageCount), activePageIndex: \(activePageIndex)")
	}
}

#if DEBUG
struct InitialViewPaginatedFeaturesIndicator_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewPaginatedFeaturesIndicator(
			pageCount: 3,
			activePageIndex: 0
		)
	}
}
#endif

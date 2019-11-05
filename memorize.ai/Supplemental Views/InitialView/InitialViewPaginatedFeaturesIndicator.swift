import SwiftUI

struct InitialViewPaginatedFeaturesIndicator: View {
	let pageCount: Int
	let activePageIndex: Int
	
	var body: some View {
		HStack {
			ForEach(0..<pageCount, id: \.self) { pageIndex in
				InitialViewPaginatedFeaturesIndicatorCircle(
					active: pageIndex == self.activePageIndex
				)
			}
		}
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
